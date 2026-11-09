//
//  PlaylistGroupPickerSheetViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/8/26.
//

import Foundation
import SwiftData

extension PlaylistGroupPickerSheet {
    @Observable
    final class ViewModel {
        let playlist: Playlist
        let context: ModelContext

        var groups: [PlaylistGroup] = []
        var newGroupName = ""

        init(
            playlist: Playlist,
            context: ModelContext
        ) {
            self.playlist = playlist
            self.context = context

            loadGroups()
        }

        func loadGroups() {
            let descriptor = FetchDescriptor<PlaylistGroup>(
                sortBy: [
                    SortDescriptor(\.primitiveName)
                ]
            )

            groups =
                (try? context.fetch(descriptor))
                ?? []
        }

        func isAlreadyInGroup(
            _ group: PlaylistGroup
        ) -> Bool {
            playlist.groups.contains {
                $0.id == group.id
            }
        }

        func addPlaylistToGroup(
            _ group: PlaylistGroup
        ) {
            guard !isAlreadyInGroup(group) else {
                return
            }

            group.groupItems.append(PlaylistGroupItem(playlistGroup: group, playlist: playlist))

            try? context.save()

            // no dismiss
        }
        
        func createGroup() {
            let name = newGroupName
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            guard !name.isEmpty
            else {
                return
            }

            let group = PlaylistGroup(
                name: name
            )

            group.groupItems.append(PlaylistGroupItem(playlistGroup: group, playlist: playlist))

            context.insert(group)

            try? context.save()
        }
    }
}
