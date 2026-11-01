//
//  PlaylistPlayerController.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/31/26.
//

import Foundation
import AVFoundation
import AVKit
import OSLog

@MainActor @Observable
final class PlaylistPlayerController: NSObject {
    private var item: QueuedPlaylistItem
    private var videoPlayer: AVPlayer?
    
//    private var bpm: Int?
    private var sequencer: PlayRateSequencer
//    private let clipStartSeconds: Double?
    
    private var playbackTask: Task<Void, Never>?
    
    init(
        item: QueuedPlaylistItem,
        sequencer: PlayRateSequencer)
    {
        self.item = item
        self.sequencer = sequencer
    }
    
    func createPlayerItem() -> AVPlayerItem {
        let playerItem = AVPlayerItem(url: item.url)

        if let endAt = item.end {
            playerItem.forwardPlaybackEndTime =
                CMTime(seconds: endAt, preferredTimescale: 600)
        }

        return playerItem
    }
    
    func attachVideoPlayer(_ player: AVPlayer) {
        self.videoPlayer = player
    }
    
    var playRate: Float {
        get { return sequencer.currentRate }
        set {
            print("Setting new playRate value. newValue: \(newValue) bpm: \(item.bpm ?? -1)")
            sequencer = SequencerFactory.createConstantPlayRateSequencer(rate: newValue, bpm: item.bpm)
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
        videoPlayer?.pause()
    }
    
    // MARK: - Async Playback Loop
    
    private func runPlaybackLoop(continuation: () -> Void) async {
        if let videoPlayer {
            await playVideoLoop(videoPlayer, startAt: item.start)
            continuation()
        }
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
