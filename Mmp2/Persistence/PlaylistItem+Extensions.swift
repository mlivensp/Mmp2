//
//  PlaylistItem+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/19/26.
//

import Foundation

extension PlaylistItem {
    static func makeDraft(
        playOrder: Int = 0,
        secondsToDelayOverride: Int? = nil,
        source: Source? = nil,
        clip: Clip? = nil,
        playback: Playback? = nil) -> PlaylistItem {
        PlaylistItem(playOrder: playOrder, secondsToDelayOverride: secondsToDelayOverride, source: source, clip: clip, playback: playback)
    }
}
