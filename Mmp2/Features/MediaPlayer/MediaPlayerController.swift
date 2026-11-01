import Foundation
import AVFoundation

@MainActor @Observable
final class MediaPlayerController: NSObject {
    let player = AVPlayer()
    
    private(set) var playableItem: PlayableItem
    private var sequencer: PlayRateSequencer
    
    private var playbackTask: Task<Void, Never>?
    
    override init() { }
    
    // MARK: - Loading

    func load(_ playableItem: PlayableItem, forPlaylist: Bool = false) throws {
        stop()
        sequencer = try SequencerFactory.createSequencer(
            from: playableItem.playback,
            bpm: playableItem.bpm,
            forPlaylist: forPlaylist
        )
        self.playableItem = playableItem
        player.replaceCurrentItem(with: makeAVPlayerItem())
    }

    func makeAVPlayerItem() -> AVPlayerItem {
        let playerItem = AVPlayerItem(url: playableItem.url)

        if let endAt = playableItem.end {
            playerItem.forwardPlaybackEndTime =
                CMTime(seconds: endAt, preferredTimescale: 600)
        }

        return playerItem
    }
    
    var playRate: Float {
        get { return sequencer.currentRate }
        set {
            print("Setting new playRate value. newValue: \(newValue) bpm: \(playableItem.bpm ?? -1)")
            sequencer = SequencerFactory.createConstantPlayRateSequencer(rate: newValue, bpm: playableItem.bpm)
            player.rate = sequencer.currentRate
            player.defaultRate = sequencer.currentRate
        }
    }
    
    var displayRate: String {
        return sequencer.displayRate
    }
    
    var position: String {
        let currentTime = player.currentTime()
        let t = CMTimeGetSeconds(currentTime)
        if !t.isNaN {
            return MediaPlayerController.formatCMTime(currentTime)
        }

        return "0:00"
    }
    
    static func formatCMTime(_ time: CMTime) -> String {
        let seconds = CMTimeGetSeconds(time)
        guard !seconds.isNaN else { return "--:--" }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]

        return formatter.string(from: seconds) ?? "--:--"
    }

    func start(continuation: @escaping () -> Void) {
        stop()
        sequencer.reset()
        
        playbackTask = Task {
            await runPlaybackLoop(continuation: continuation)
        }
    }
    
    func stop() {
        playbackTask?.cancel()
        playbackTask = nil
        player.pause()
    }
    
    // MARK: - Async Playback Loop
    
    private func runPlaybackLoop(continuation: () -> Void) async {
        await playVideoLoop(player, startAt: playableItem.start)
        continuation()
    }
    
    // MARK: - Video
    
    private func playVideoLoop(_ player: AVPlayer, startAt: Double?) async {
        let startTime: CMTime?
        
        if let startAt {
            startTime = CMTime(seconds: startAt, preferredTimescale: 600)
        } else {
            startTime = nil
        }
        
        guard let item = player.currentItem else { return }
        let iterator = NotificationCenter.default
            .notifications(named: .AVPlayerItemDidPlayToEndTime, object: item)
            .makeAsyncIterator()
        
        while !Task.isCancelled {
            guard let rate = sequencer.nextRate() else {
                stop()
                return
            }
            
            if Task.isCancelled { return }
            
            if let startTime {
                await seekPlayer(player, to: startTime)
            } else {
                await seekPlayer(player, to: .zero)
            }
            
            player.defaultRate = Float(rate)
            player.rate = Float(rate)
            
            // Suspends until the clip end or media end is reached.
            guard await iterator.next() != nil else {
                return
            }
        }
    }
    
    func seekPlayer(_ player: AVPlayer, to time: CMTime) async {
        await withCheckedContinuation { continuation in
            player.seek(to: time) { _ in
                continuation.resume()
            }
        }
    }
}
