//
//  Clip+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/29/26.
//

import Foundation

extension Clip {
    static func makeDraft() -> Clip {
        Clip(
            source: nil,
            name: "",
            startSeconds: 0,
            endSeconds: 0,
            startMeasure: nil,
            endMeasure: nil,
            isFavorite: false,
            notes: nil,
            media: Media.makeDraft(),
            playback: Playback.makeDraft()
        )
    }
}
