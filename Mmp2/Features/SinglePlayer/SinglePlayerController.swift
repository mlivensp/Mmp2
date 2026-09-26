import Foundation
import AVFoundation
import AVKit

//final class LinearPlayRateSequencer: PlayRateSequencer {
//    private var rates: [Float]
//    private var index = 0
//
//    init(rates: [Float]) {
//        self.rates = rates
//    }
//
//    func nextRate() -> Float? {
//        guard index < rates.count else { return nil }
//        defer { index += 1 }
//        return rates[index]
//    }
//
//    func reset() {
//        index = 0
//    }
//}

@MainActor @Observable
final class SinglePlayerController {
    //    private var audioPlayer: AVAudioPlayer?
    private var videoPlayer: AVPlayer?
    
    private var bpm: Int?
    private var sequencer: PlayRateSequencer
    private let clipStart: Double?
    private let clipEnd: Double?
    
    private var playbackTask: Task<Void, Never>?
    
    init(
        bpm: Int?,
        clipStart: Double? = nil,
        clipEnd: Double? = nil,
        sequencer: PlayRateSequencer)
    {
        self.clipStart = clipStart
        self.clipEnd = clipEnd
        self.sequencer = sequencer
    }
    
    //    func attachAudioPlayer(_ player: AVAudioPlayer) {
    //        self.audioPlayer = player
    //    }
    
    func attachVideoPlayer(_ player: AVPlayer) {
        self.videoPlayer = player
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }
    
    var playRate: Float {
        get { return sequencer.currentRate }
        set {
            sequencer = SequencerFactory.createConstantPlayRateSequencer(rate: newValue, bpm: bpm)
            videoPlayer?.rate = sequencer.currentRate
        }
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
        
        //        audioPlayer?.stop()
        videoPlayer?.pause()
    }
    
    @objc private func playerDidReachEnd(_ notification: Notification) {
        if let nextRate = sequencer.nextRate() {
            if let videoPlayer {
                let start = clipStart ?? 0
                let startTime = CMTime(seconds: start, preferredTimescale: 600)
                videoPlayer.seek(to: startTime) { _ in
                    videoPlayer.rate = Float(nextRate)
                }
            } /* else if let audioPlayer {
               let start = clipStart ?? 0
               audioPlayer.currentTime = start
               audioPlayer.rate = Float(nextRate)
               audioPlayer.play()
               } */
        } else {
            stop()
        }
    }
    
    // MARK: - Async Playback Loop
    
    private func runPlaybackLoop() async {
        //        if let audioPlayer {
        //            await playAudioLoop(audioPlayer)
        //        } else
        if let videoPlayer {
            await playVideoLoop(videoPlayer)
        }
    }
    
    // MARK: - Audio
    
    //    private func playAudioLoop(_ player: AVAudioPlayer) async {
    //        guard let start = clipStart, let end = clipEnd else {
    //            player.play()
    //            return
    //        }
    //
    //        player.enableRate = true
    //
    //        while !Task.isCancelled {
    //            guard let rate = sequencer.nextRate() else {
    //                stop()
    //                return
    //            }
    //
    //            player.rate = Float(rate)
    //            player.currentTime = start
    //            player.play()
    //
    //            // Wait until reaching end
    //            await waitUntilAudioReaches(player, endTime: end)
    //
    ////            if !loopEnabled {
    ////                stop()
    ////                return
    ////            }
    //        }
    //    }
    //
    //    private func waitUntilAudioReaches(_ player: AVAudioPlayer, endTime: TimeInterval) async {
    //        while player.currentTime < endTime {
    //            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
    //            if Task.isCancelled { return }
    //        }
    //    }
    
    // MARK: - Video
    
    private func playVideoLoop(_ player: AVPlayer) async {
        guard let start = clipStart, let end = clipEnd else {
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
