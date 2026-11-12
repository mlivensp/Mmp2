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
    static func makeDraft(
        name: String = "",
        sortOrder: Int = 0,
        measure1Start: Double? = nil,
        isFavorite: Bool = false,
        isExpanded: Bool = false,
        notes: String? = nil,
        bpm: Int? = nil,
        duration: Double = 0,
        lastPlayed: Date? = nil,
        numberTimesPlayed: Int = 0,
        path: String = "",
        pathIsValid: Bool = false,
        bookmark: Data? = nil,
        mediaCollection: MediaCollection,
        playback: Playback? = nil,
        sourceGroup: SourceGroup? = nil
    ) -> Source {
        let draftPlayback = playback ?? Playback.makeDraft()
        
        return Source(
            name: name,
            sortOrder: sortOrder,
            measure1Start: measure1Start,
            isFavorite: isFavorite,
            isExpanded: isExpanded,
            notes: notes,
            bpm: bpm,
            duration: duration,
            lastPlayed: lastPlayed,
            numberTimesPlayed: numberTimesPlayed,
            path: path,
            pathIsValid: pathIsValid,
            bookmark: bookmark,
            mediaCollection: mediaCollection,
            playback: draftPlayback,
            sourceGroup: sourceGroup
        )
    }

    public func resolveURL() throws -> URL? {
        guard let bookmark = bookmark else { return nil }
        
        let url: URL
        var isStale = false
        
        do {
            url = try URL(
                resolvingBookmarkData: bookmark,
                options: [.withoutUI, .withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            if isStale {
                print("⚠️ Stale bookmark for media")
                // TODO: trigger re-bookmark flow
                return nil
            }
            
            let ok = url.startAccessingSecurityScopedResource()
            print("startAccessingSecurityScopedResource = \(ok) for \(url.path)")
            
            guard ok else {
                print("❌ Failed to start security-scoped access for \(url.path)")
                return nil
            }
            
            print("✅ resolvedURL - \(url.absoluteString)")
        } catch {
            print("❌ resolveURL error: \(error)")
            return nil
        }
        
        return url
    }
}
