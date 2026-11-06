//
//  URL+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/16/26.
//

import Foundation

extension URL {

    static func rebaseCrossPlatform(_ rawPath: String, on root: URL) -> URL? {

        // Normalize incoming path
        let posix = rawPath
            .replacingOccurrences(of: "\\", with: "/")
            .replacingOccurrences(of: "C:/", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        let rawComponents = posix
            .split(separator: "/")
            .map(String.init)

        let rootComponents = root.path
            .split(separator: "/")
            .map(String.init)

        guard let overlapRange = longestRootSuffixMatch(
            raw: rawComponents,
            root: rootComponents
        ) else {
            return nil
        }

        // Everything after the matched suffix becomes relative
        let relativeComponents = rawComponents.dropFirst(overlapRange.upperBound)

        var result = root

        for component in relativeComponents {
            result.appendPathComponent(component)
        }

        return result.standardizedFileURL
    }

    /// Finds the longest suffix of `root` that appears as a contiguous
    /// sequence anywhere within `raw`.
    private static func longestRootSuffixMatch(
        raw: [String],
        root: [String]
    ) -> Range<Int>? {

        let normalizedRaw = raw.map(normalizeComponent)
        let normalizedRoot = root.map(normalizeComponent)

        // Try longest suffix first.
        for suffixStart in normalizedRoot.indices {

            let suffix = Array(normalizedRoot[suffixStart...])

            guard suffix.count <= normalizedRaw.count else {
                continue
            }

            for rawStart in 0...(normalizedRaw.count - suffix.count) {

                let rawEnd = rawStart + suffix.count

                if Array(normalizedRaw[rawStart..<rawEnd]) == suffix {
                    return rawStart..<rawEnd
                }
            }
        }

        return nil
    }

    private static func normalizeComponent(_ component: String) -> String {
        component
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive],
                     locale: .current)
    }
}
