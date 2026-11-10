//
//  PlaylistController.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/31/26.
//

import Foundation
import OSLog

@MainActor @Observable
final class PlaylistController {
    let player = MediaPlayerController()
    
    private let items: [PlaylistPlaybackItem]
    private let repeatCount: Int?          // total passes, >= 1
    private var pass = 0
    private var index = 0
    private var loadedInPass = false
    
    private(set) var current: PlayableItem?
    private var isStopped = false
    private var accessReleased = false
    
    private(set) var playbackState: PlaylistPlaybackState?
    private var countdownTask: Task<Void, Never>?
    
    init(items: [PlaylistPlaybackItem], repeatCount: Int? = 1) {
        self.items = items
        self.repeatCount = repeatCount.map { max(1, $0) }
    }
    
    /// Calls onFinished when the last item of the last pass completes.
    func start(onFinished: @escaping () -> Void) {
        guard !accessReleased else { return }
        isStopped = false
        accessReleased = false
        pass = 0
        index = 0
        loadedInPass = false
        playbackState = nil
        countdownTask?.cancel()
        countdownTask = nil
        playCurrent(onFinished: onFinished)
    }
    
    func stop() {
        isStopped = true

        countdownTask?.cancel()
        countdownTask = nil

        player.stop()
        releaseSecurityScopedAccess()
    }
    
    private func releaseSecurityScopedAccess() {
        guard !accessReleased else { return }
        accessReleased = true
        
        for item in items {
            item.playableItem.url.stopAccessingSecurityScopedResource()
        }
    }
    
    private func playCurrent(onFinished: @escaping () -> Void) {
        guard !isStopped else { return }
        guard index < items.count else { return onFinished() }
        let item = items[index]
        do {
            try player.load(item.playableItem, forPlaylist: true)
            loadedInPass = true
            current = item.playableItem
        } catch {
            Logger.ui.error("Skipping item: \(error.localizedDescription)")
            return advance(onFinished: onFinished)
        }
        
        if item.delaySeconds > 0 {
            beginCountdown(
                seconds: item.delaySeconds,
                item: item.playableItem,
                onFinished: onFinished
            )
        } else {
            startPlayback(
                item: item.playableItem,
                onFinished: onFinished
            )
        }    }
    
    private func startPlayback(
        item: PlayableItem,
        onFinished: @escaping () -> Void
    ) {
        playbackState = .playing(current: item)

        player.start { [weak self] in
            self?.advance(onFinished: onFinished)
        }
    }
    private func beginCountdown(
        seconds: Int,
        item: PlayableItem,
        onFinished: @escaping () -> Void
    ) {
        countdownTask?.cancel()
        
        countdownTask = Task { @MainActor in
            
            for remaining in stride(
                from: seconds,
                through: 1,
                by: -1
            ) {
                guard !Task.isCancelled, !isStopped else {
                    return
                }
                
                playbackState = .countingDown(
                    upcoming: item,
                    secondsRemaining: remaining
                )

                try? await Task.sleep(for: .seconds(1))
            }
            
            guard !Task.isCancelled, !isStopped else {
                return
            }
            
            startPlayback(
                item: item,
                onFinished: onFinished
            )
        }
    }
    
    // loadedInPass prevents infinite recursion if all items in playlist fail to load
    private func advance(onFinished: @escaping () -> Void) {
        guard !isStopped else { return }
        index += 1
        if index >= items.count {
            guard loadedInPass else {
                playbackState = .finished
                return onFinished()
            }

            loadedInPass = false
            pass += 1
            
            if let repeatCount, pass >= repeatCount {
                playbackState = .finished
                return onFinished()
            }

            index = 0
        }
        playCurrent(onFinished: onFinished)
    }
}
