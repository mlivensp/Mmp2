//
//  Playlist+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/25/26.
//

import Foundation

extension Playlist {
    static func makeDraft(
        name: String = "",
        shuffle: Bool = false,
        defaultSecondsToDelay: Int = 5,
        duration: TimeInterval = .zero,
        timesToPlay: Int? = 1,
        notes: String? = nil) -> Playlist {
            Playlist(name: name, shuffle: shuffle, defaultSecondsToDelay: defaultSecondsToDelay, duration: duration, timesToPlay: timesToPlay, notes: notes)
    }
}
