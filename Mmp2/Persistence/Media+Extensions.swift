//
//  Media+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/6/26.
//

import Foundation
import SwiftData

extension Media {
    static func makeDraft() -> Media {
        let media = Media(bpm: nil, path: "")
        return media
    }
}

extension Media {
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
