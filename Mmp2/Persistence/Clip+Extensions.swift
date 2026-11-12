//
//  Clip+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/29/26.
//

import Foundation

extension Clip {
    static func makeDraft(
        name: String = "",
        startSeconds: Double = 0,
        endSeconds: Double = 0,
        firstMeasure: Int? = nil,
        lastMeasure: Int? = nil,
        isFavorite: Bool = false,
        bpm: Int? = nil,
        duration: Double = 0,
        lastPlayed: Date? = nil,
        numberTimesPlayed: Int = 0,
        notes: String? = nil,
        source: Source,
        playback: Playback? = nil
    ) -> Clip {
        let draftPlayback = playback ?? Playback.makeDraft()
        return Clip(
            name: name,
            startSeconds: startSeconds,
            endSeconds: endSeconds,
            startMeasure: firstMeasure,
            endMeasure: lastMeasure,
            isFavorite: isFavorite,
            bpm: bpm,
            duration: duration,
            lastPlayed: lastPlayed,
            numberTimesPlayed: numberTimesPlayed,
            notes: notes,
            source: source,
            playback: draftPlayback
        )
    }
}
