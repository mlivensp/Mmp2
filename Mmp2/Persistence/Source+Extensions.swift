//
//  Source+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/6/26.
//

import Foundation
import SwiftData

extension Source {
    var effectiveSortOrder: Int {
        (sourceGroup == nil ? sortOrder : sourceGroup?.sortOrder) ?? 0
    }
//    
//    static func createNew() -> Source {
//        let media = Media.createNew()
//        let playback = Playback.createNew()
//        return Source(name: "", sortOrder: 0, measure1Start: nil, isFavorite: false, notes: nil, media: media, playback: playback, sourceGroup: nil)
//    }
}

extension Source {
    /// Detached draft: not inserted, not linked to a collection.
    static func makeDraft(sortOrder: Int) -> Source {
        Source(
            name: "",
            sortOrder: sortOrder,
            measure1Start: nil,
            isFavorite: false,
            notes: nil,
            media: Media.makeDraft(),
            playback: Playback(),
            sourceGroup: nil
        )
    }
}
