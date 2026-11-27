//
//  PlaylistItemPickerSheet.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/9/26.
//

import SwiftData
import SwiftUI

struct PlaylistItemPickerSheet: View {
    let playlistVM: PlaylistEditView.ViewModel
    
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
                            )
                        ) {
                            
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
            playlistVM.playlistItems.compactMap {
                $0.playlistItem.source?.persistentModelID
            }
        )
        
        selectedClipIds = Set(
            playlistVM.playlistItems.compactMap {
                $0.playlistItem.clip?.persistentModelID
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
            playlistVM.playlistItems.compactMap {
                $0.playlistItem.source?.persistentModelID
            }
        )
        
        let existingClipIds = Set(
            playlistVM.playlistItems.compactMap {
                $0.playlistItem.clip?.persistentModelID
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
        playlistVM.playlistItems.filter { item in
            
            if let source = item.playlistItem.source {
                return sourceIdsToRemove.contains(
                    source.persistentModelID
                )
            }
            
            if let clip = item.playlistItem.clip {
                return clipIdsToRemove.contains(
                    clip.persistentModelID
                )
            }
            
            return false
        }
        
        playlistItemsToRemove.forEach { itemToRemove in
            if let index = playlistVM.playlistItems.firstIndex(where: { $0.id == itemToRemove.id }) {
                playlistVM.playlistItems.remove(at: index)
            }
        }
    }
    
    private var nextSortOrder: Int {
        (playlistVM.playlistItems.map(\.sortOrder).max() ?? 0) + 1
    }
    
    private func addItems(
        sourceIdsToAdd: Set<PersistentIdentifier>,
        clipIdsToAdd: Set<PersistentIdentifier>
    ) {
        var sortOrder = nextSortOrder
        
        for sourceId in sourceIdsToAdd {
            if let source = modelContext.model(for: sourceId) as? Source {
                let item = PlaylistItem.makeDraft(playOrder: sortOrder, source: source)
                let itemVM = PlaylistItemViewModel(playlistItem: item, isNew: true)
                playlistVM.playlistItems.append(itemVM)
                sortOrder += 1
            }
        }
        
        for clipId in clipIdsToAdd {
            if let clip = modelContext.model(for: clipId) as? Clip {
                let item = PlaylistItem.makeDraft(playOrder: sortOrder, clip: clip)
                let itemVM = PlaylistItemViewModel(playlistItem: item)
                playlistVM.playlistItems.append(itemVM)
                sortOrder += 1
            }
        }
    }
}
//#Preview {
//    PlaylistItemPickerSheet()
//}
