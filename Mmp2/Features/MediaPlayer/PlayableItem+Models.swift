//
//  PlayableItem+Models.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/31/26.
//

import Foundation
import Foundation

extension PlayableItem {
    /// Caller supplies an already-resolved URL, so it owns the security-scoped access.
    init(source: Source, url: URL, playback: Playback? = nil) {
        self.init(
            url: url,
            title: Self.title(source.mediaCollection?.primitiveName, source.primitiveName),
            start: nil,
            end: nil,
            bpm: source.media.bpm,
            playback: playback ?? source.playback)
    }

    init?(clip: Clip, url: URL, playback: Playback? = nil) {
        guard let source = clip.source else { return nil }
        self.init(
            url: url,
            title: Self.title(source.mediaCollection?.primitiveName, source.primitiveName, clip.primitiveName),
            start: clip.startSeconds,
            end: clip.endSeconds,
            bpm: clip.media.bpm,
            playback: playback ?? clip.playback)
    }

    private static func title(_ parts: String?...) -> String {
        parts.map { $0 ?? "?" }.joined(separator: " • ")
    }
}

extension PlaylistItem {
    /// Resolves the media URL, which starts security-scoped access (released by PlaylistController.stop()).
    func makePlayableItem() -> PlayableItem? {
        if let source {
            guard let url = try? source.media.resolveURL() else { return nil }
            return PlayableItem(source: source, url: url, playback: playback)
        } else if let clip {
            guard let source = clip.source, let url = try? source.media.resolveURL() else { return nil }
            return PlayableItem(clip: clip, url: url, playback: playback)
        }
        return nil // TODO: log
    }
}
