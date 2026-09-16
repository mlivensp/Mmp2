//
//  SourcesList.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import SwiftUI

struct SourcesList: View {
    let collection: MediaCollection

    // Combined list of top-level items
    private var topLevelItems: [TopLevelItem] {
        var items: [TopLevelItem] = []

        // 1. Source Groups (sorted)
        let groups = (collection.sourceGroups ?? [])
            .sorted { $0.sortOrder < $1.sortOrder }   // or by name if you prefer
        items += groups.map { .group($0) }

        // 2. Ungrouped sources
        let ungrouped = (collection.sources ?? [])
            .filter { $0.sourceGroup == nil }
            .sorted { ($0.sortOrder) < ($1.sortOrder) }

        items += ungrouped.map { .source($0) }

        return items
    }

    var body: some View {
        List {
            ForEach(topLevelItems) { item in
                switch item {
                case .group(let group):
                    DisclosureGroup {
                        // Sources inside the group
                        ForEach(group.sources ?? []) { source in
                            SourceRow(source: source)
                        }
                    } label: {
                        Label(group.primitiveName, systemImage: "folder.fill")
                    }
                    
                case .source(let source):
                    if let clips = source.clips, !clips.isEmpty {
                        DisclosureGroup {
                            ForEach(clips) { clip in
                                ClipRow(clip: clip)
                            }
                        } label: {
                            SourceRow(source: source)
                        }
                    } else {
                        SourceRow(source: source)
                    }
                }
            }
        }
        .listStyle(.sidebar)          // optional – looks nice in a split view
    }
}
//#Preview {
//    SourcesList()
//}
