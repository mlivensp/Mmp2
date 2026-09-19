//
//  URL+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/16/26.
//

import Foundation

extension URL {

    static func rebaseCrossPlatform(_ rawPath: String, on root: URL) -> URL? {
        // Normalize Windows → POSIX
        let posix = rawPath
            .replacingOccurrences(of: "\\", with: "/")
            .replacingOccurrences(of: "C:/", with: "")
            .replacingOccurrences(of: "c:/", with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        let rawComponents = posix.split(separator: "/").map(String.init)
        let rootComponents = root.path.split(separator: "/").map(String.init)

        // Find overlap (prefix of raw vs suffix of root)
        let overlap = overlapComponents(raw: rawComponents, root: rootComponents)

        // Remove overlap from raw path
        let trimmed = Array(rawComponents.dropFirst(overlap.count))

        // Build final URL
        var finalURL = root
        for component in trimmed {
            finalURL.appendPathComponent(component)
        }

        return finalURL.standardizedFileURL
    }

    private static func overlapComponents(raw: [String], root: [String]) -> [String] {
        var overlap: [String] = []

        var rawIndex = 0
        var rootIndex = root.count - 1

        while rawIndex < raw.count && rootIndex >= 0 {
            if raw[rawIndex] == root[rootIndex] {
                overlap.append(raw[rawIndex])
                rawIndex += 1
                rootIndex -= 1
            } else {
                break
            }
        }

        return overlap
    }
}
