//
//  SourceLocatorActor.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/16/26.
//

import Foundation
import SwiftData

@ModelActor
actor SourceLocatorActor {
    private let backgroundQueue = DispatchQueue.global(qos: .utility)

    struct Progress {
        let checked: Int
        let total: Int
    }

    func repairPaths(
        in directoryURL: URL,
        mediaItems: [Media],
        progressHandler: @escaping (Progress) -> Void
    ) async throws {

        let total = mediaItems.count

        // Security scope MUST be activated on the same thread that will create bookmarks.
        print("Accessing:", directoryURL.startAccessingSecurityScopedResource())
        print("URL is file URL:", directoryURL.isFileURL)
        print("Path:", directoryURL.path)
        // … then try the bookmark
//        let canAccess = directoryURL.startAccessingSecurityScopedResource()
        defer { directoryURL.stopAccessingSecurityScopedResource() }

        for (index, media) in mediaItems.enumerated() {
            try Task.checkCancellation()

            guard let rebasedURL = await URL.rebaseCrossPlatform(media.path ?? "", on: directoryURL)
            else {
                await MainActor.run {
                    progressHandler(.init(checked: index + 1, total: total))
                }
                continue
            }

            let exists = await checkFileExists(at: rebasedURL)

            if exists {
                // Bookmark creation MUST happen inside the actor (Option A)
                await updateMedia(media, with: rebasedURL)
            }

            await MainActor.run {
                progressHandler(.init(checked: index + 1, total: total))
            }
        }
    }

    /// Background queue ONLY checks file existence.
    private func checkFileExists(at url: URL) async -> Bool {
        await withCheckedContinuation { continuation in
            backgroundQueue.async {
                let parent = url.deletingLastPathComponent().path

                do {
                    _ = try FileManager.default.contentsOfDirectory(atPath: parent)
                    continuation.resume(returning: FileManager.default.fileExists(atPath: url.path))
                } catch {
                    continuation.resume(returning: false)
                }
            }
        }
    }

    /// Bookmark creation MUST happen inside the actor (same thread as security scope).
    private func updateMedia(_ media: Media, with url: URL) async {
        do {
            let bookmarkData = try url.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )

            media.bookmark = bookmarkData
            media.path = url.path  // Store POSIX path
            media.pathIsValid = true
            print("about to save media with path \(media.path)")
            try modelContext.save()
        } catch {
            print("Error saving media: \(error)")
        }
    }
}
