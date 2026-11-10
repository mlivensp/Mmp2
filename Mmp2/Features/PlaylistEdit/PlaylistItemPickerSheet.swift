//
//  PlaylistItemPickerSheet.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/9/26.
//

import SwiftData
import SwiftUI

struct PlaylistItemPickerSheet: View {
    let playlist: Playlist

    @Environment(\.modelContext)
    private var modelContext
    
    @Environment(\.dismiss)
    private var dismiss

    @Query(sort: \MediaCollection.name_normalized)
    private var mediaCollections: [MediaCollection]
    
    @State private var collections: [TopLevelCollection] = []
    @State private var selectedSourceIds: Set<PersistentIdentifier> = []
    @State private var selectedClipIds: Set<PersistentIdentifier> = []
    @State private var expandedCollectionIds: Set<PersistentIdentifier> = []
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Select Items For Playlist")
                .font(.headline)
            Divider()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(collections) { wrapper in
                        
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: {
                                    expandedCollectionIds.contains(wrapper.id)
                                },
                                set: { isExpanded in
                                    if isExpanded {
                                        expandedCollectionIds.insert(wrapper.id)
                                    } else {
                                        expandedCollectionIds.remove(wrapper.id)
                                    }
                                }
                            )                ) {
                                
                                PlaylistCollectionSection(
                                    mediaCollection: wrapper.collection,
                                    selectedSourceIds: $selectedSourceIds,
                                    selectedClipIds: $selectedClipIds
                                )
                                
                            } label: {
                                
                                Text(wrapper.collection.primitiveName)
                                    .font(.headline)
                            }
                    }
                }
            }
            
            Divider()

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }

                Button("Done") {
                    applySelections()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .padding(formPadding)
        .navigationTitle("Add Playlist Items")
        .frame(
            width: 700,
            height: 650
        )
        .onAppear {
            loadSelections()

            collections = mediaCollections.map {
                TopLevelCollection(collection: $0)
            }
        }
    }
    
    private func loadSelections() {
        selectedSourceIds = Set(
            playlist.playlistItems.compactMap {
                $0.source?.persistentModelID
            }
        )

        selectedClipIds = Set(
            playlist.playlistItems.compactMap {
                $0.clip?.persistentModelID
            }
        )
    }
    
    func toggle(source: Source) {
        let id = source.persistentModelID

        if selectedSourceIds.contains(id) {
            selectedSourceIds.remove(id)
        } else {
            selectedSourceIds.insert(id)
        }
    }
    
    func toggle(clip: Clip) {
        let id = clip.persistentModelID

        if selectedClipIds.contains(id) {
            selectedClipIds.remove(id)
        } else {
            selectedClipIds.insert(id)
        }
    }
    
    private func applySelections() {
        let existingSourceIds = Set(
            playlist.playlistItems.compactMap {
                $0.source?.persistentModelID
            }
        )

        let existingClipIds = Set(
            playlist.playlistItems.compactMap {
                $0.clip?.persistentModelID
            }
        )

        let sourceIdsToAdd =
            selectedSourceIds.subtracting(existingSourceIds)

        let clipIdsToAdd =
            selectedClipIds.subtracting(existingClipIds)

        let sourceIdsToRemove =
            existingSourceIds.subtracting(selectedSourceIds)

        let clipIdsToRemove =
            existingClipIds.subtracting(selectedClipIds)

        removeItems(
            sourceIdsToRemove: sourceIdsToRemove,
            clipIdsToRemove: clipIdsToRemove
        )

        addItems(
            sourceIdsToAdd: sourceIdsToAdd,
            clipIdsToAdd: clipIdsToAdd
        )

        try? modelContext.save()
    }
    
    private func removeItems(
        sourceIdsToRemove: Set<PersistentIdentifier>,
        clipIdsToRemove: Set<PersistentIdentifier>
    ) {
        let playlistItemsToRemove =
            playlist.playlistItems.filter { item in

                if let source = item.source {
                    return sourceIdsToRemove.contains(
                        source.persistentModelID
                    )
                }

                if let clip = item.clip {
                    return clipIdsToRemove.contains(
                        clip.persistentModelID
                    )
                }

                return false
            }

        playlistItemsToRemove.forEach {
            modelContext.delete($0)
        }
    }
    
    private var nextSequence: Int {
        (playlist.playlistItems.map(\.sequence).max() ?? -1) + 1
    }
    
    private func addItems(
        sourceIdsToAdd: Set<PersistentIdentifier>,
        clipIdsToAdd: Set<PersistentIdentifier>
    ) {
        var sequence =
            (playlist.playlistItems.map(\.sequence).max() ?? -1) + 1

        for collection in mediaCollections {

            for source in collection.sources {

                if sourceIdsToAdd.contains(
                    source.persistentModelID
                ) {

                    let item = PlaylistItem(
                        sequence: sequence,
                        source: source,
                        playlist: playlist
                    )

                    modelContext.insert(item)

                    sequence += 1
                }

                for clip in source.clips {

                    if clipIdsToAdd.contains(
                        clip.persistentModelID
                    ) {

                        let item = PlaylistItem(
                            sequence: sequence,
                            clip: clip,
                            playlist: playlist
                        )

                        modelContext.insert(item)

                        sequence += 1
                    }
                }
            }
        }
    }
}
//#Preview {
//    PlaylistItemPickerSheet()
//}
