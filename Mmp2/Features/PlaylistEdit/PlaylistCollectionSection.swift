//
//  PlaylistCollectionSection.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/9/26.
//

import SwiftData
import SwiftUI

struct PlaylistCollectionSection: View {
    let mediaCollection: MediaCollection
    @Binding var selectedSourceIds: Set<PersistentIdentifier>
    @Binding var selectedClipIds: Set<PersistentIdentifier>
    
    private var topLevelItems: [TopLevelSourceItem] {
        var items: [TopLevelSourceItem] = []

        let groups = mediaCollection.sourceGroups.map {
            TopLevelSourceGroup(
                sourceGroup: $0,
                sources: topLevelSources($0.sources)
            )
        }

        items += groups.map { .group($0) }

        let ungroupedSources = mediaCollection.sources
            .filter { $0.sourceGroup == nil }
            .map { TopLevelSource(source: $0) }

        items += ungroupedSources.map { .source($0) }

        return items.sorted {
            $0.sortOrder < $1.sortOrder
        }
    }

    private func topLevelSources(
        _ sources: [Source]
    ) -> [TopLevelSource] {

        sources
            .map { TopLevelSource(source: $0) }
            .sorted {
                $0.sortOrder < $1.sortOrder
            }
    }

    var body: some View {
        ForEach(topLevelItems) { item in

            switch item {

            case .group(let wrapper):
                PlaylistPickerGroupSection(
                    wrapper: wrapper,
                    selectedSourceIds: $selectedSourceIds,
                    selectedClipIds: $selectedClipIds
                )

            case .source(let wrapper):
                PlaylistPickerSourceSection(
                    wrapper: wrapper,
                    selectedSourceIds: $selectedSourceIds,
                    selectedClipIds: $selectedClipIds
                )
            }
        }
    }
}
//#Preview {
//    PlaylistCollectionSection()
//}
