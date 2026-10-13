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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
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
    
    @objc private func playerDidReachEnd(_ notification: Notification) async {
        if let nextRate = sequencer.nextRate() {
            if let videoPlayer {
                videoPlayer.pause()
                videoPlayer.rate = Float(nextRate)
                videoPlayer.defaultRate = Float(nextRate)
                await playVideoLoop(videoPlayer)
            }
        } else {
            stop()
        }
    }
    
    // MARK: - Async Playback Loop
    
    private func runPlaybackLoop() async {
        if let videoPlayer {
            await playVideoLoop(videoPlayer)
        }
    }
    
    // MARK: - Video
    
    private func playVideoLoop(_ player: AVPlayer) async {
        guard let start = clipStartSeconds, let end = clipEndSeconds else {
            player.play()
            return
        }
        
        let startTime = CMTime(seconds: start, preferredTimescale: 600)
        let endTime = CMTime(seconds: end, preferredTimescale: 600)
        
        while !Task.isCancelled {
            guard let rate = sequencer.nextRate() else {
                stop()
                return
            }
            
            await player.seek(to: startTime)
            player.rate = Float(rate)
            player.defaultRate = Float(rate)
            
            await waitUntilVideoReaches(player, endTime: endTime)
        }
    }
    
    private func waitUntilVideoReaches(_ player: AVPlayer, endTime: CMTime) async {
        while player.currentTime() < endTime {
            try? await Task.sleep(nanoseconds: 50_000_000)
            if Task.isCancelled { return }
        }
    }
}
