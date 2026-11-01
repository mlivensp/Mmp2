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

    private let items: [PlayableItem]
    private let repeatCount: Int?          // total passes, >= 1
    private var pass = 0
    private var index = 0
    private var loadedInPass = false

    private(set) var current: PlayableItem?
    private var isStopped = false
    private var accessReleased = false

    init(items: [PlayableItem], repeatCount: Int? = 1) {
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
        playCurrent(onFinished: onFinished)
    }

    func stop() {
        isStopped = true
        player.stop()
        releaseSecurityScopedAccess()
    }
    
    private func releaseSecurityScopedAccess() {
        guard !accessReleased else { return }
        accessReleased = true
        
        for item in items {
            item.url.stopAccessingSecurityScopedResource()
        }
    }

    private func playCurrent(onFinished: @escaping () -> Void) {
        guard !isStopped else { return }
        guard index < items.count else { return onFinished() }
        let item = items[index]
        do {
            try player.load(item, forPlaylist: true)
            loadedInPass = true
            current = item
        } catch {
            Logger.ui.error("Skipping item: \(error.localizedDescription)")
            return advance(onFinished: onFinished)
        }
        player.start { [weak self] in
            self?.advance(onFinished: onFinished)
        }
    }

    // loadedInPass prevents infinite recursion if all items in playlist fail to load
    private func advance(onFinished: @escaping () -> Void) {
        guard !isStopped else { return }
        index += 1
        if index >= items.count {
            guard loadedInPass else { return onFinished() }
            loadedInPass = false
            pass += 1
            if let repeatCount, pass >= repeatCount {
                return onFinished()
            }
            index = 0
        }
        playCurrent(onFinished: onFinished)
    }
}
