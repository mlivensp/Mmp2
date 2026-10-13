import Foundation
import AVFoundation
import AVKit
import OSLog

@MainActor @Observable
final class SinglePlayerController: NSObject {
    private var videoPlayer: AVPlayer?
    
    private var bpm: Int?
    private var sequencer: PlayRateSequencer
    private let clipStartSeconds: Double?
    private let clipEndSeconds: Double?
    
    private var playbackTask: Task<Void, Never>?
    
    init(
        bpm: Int?,
        clipStartSeconds: Double? = nil,
        clipEndSeconds: Double? = nil,
        sequencer: PlayRateSequencer)
    {
        self.bpm = bpm
        self.clipStartSeconds = clipStartSeconds
        self.clipEndSeconds = clipEndSeconds
        self.sequencer = sequencer
    }
    
    func attachVideoPlayer(_ player: AVPlayer) {
        self.videoPlayer = player
        
        let start = clipStartSeconds ?? 0
        let startTime = CMTime(seconds: start, preferredTimescale: 600)
        player.seek(to: startTime) { _ in
            Logger.data.info("attachVideoPlayer seekTo")
        }
    }
    
    var playRate: Float {
        get { return sequencer.currentRate }
        set {
            print("Setting new playRate value. newValue: \(newValue) bpm: \(bpm ?? -1)")
            sequencer = SequencerFactory.createConstantPlayRateSequencer(rate: newValue, bpm: bpm)
            videoPlayer?.rate = sequencer.currentRate
            videoPlayer?.defaultRate = sequencer.currentRate
        }
    }
    
    var displayRate: String {
        return sequencer.displayRate
    }
    
    var position: String {
        guard let videoPlayer else { return "0:00" }
        let t = CMTimeGetSeconds(videoPlayer.currentTime())
        if !t.isNaN {
            return formatCMTime(videoPlayer.currentTime())
        }

        return "0:00"
    }
    
    func formatCMTime(_ time: CMTime) -> String {
        let seconds = CMTimeGetSeconds(time)
        guard !seconds.isNaN else { return "--:--" }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]

        return formatter.string(from: seconds) ?? "--:--"
    }

    func start() {
        stop()
        sequencer.reset()
        
        playbackTask = Task {
            await runPlaybackLoop()
        }
    }
    
    func stop() {
        playbackTask?.cancel()
        playbackTask = nil
        videoPlayer?.pause()
    }
    
    // MARK: - Async Playback Loop
    
    private func runPlaybackLoop() async {
        if let videoPlayer {
            await playVideoLoop(videoPlayer)
        }
    }
    
    // MARK: - Video
    
    private func playVideoLoop(_ player: AVPlayer) async {
        guard let item = player.currentItem else { return }
        
        let startTime = CMTime(seconds: clipStartSeconds ?? 0, preferredTimescale: 600)
        if let end = clipEndSeconds {
            item.forwardPlaybackEndTime = CMTime(seconds: end, preferredTimescale: 600)
        }
        
        while !Task.isCancelled {
            guard let rate = sequencer.nextRate() else {
                stop()
                return
            }
            
            // Subscribe before starting playback so the end notification can't be missed.
            var endNotifications = NotificationCenter.default
                .notifications(named: .AVPlayerItemDidPlayToEndTime, object: item)
                .makeAsyncIterator()
            
            await player.seek(to: startTime, toleranceBefore: .zero, toleranceAfter: .zero)
            if Task.isCancelled { return }
            player.defaultRate = Float(rate)
            player.rate = Float(rate)
            
            // Suspends until the clip end or media end is reached.
            guard await endNotifications.next() != nil else { return }
        }
    }
}
