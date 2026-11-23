//
//  SourcesList.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import SwiftUI

struct SourcesList: View {
    @Environment(AppRootManager.self) private var appRootManager
    
    let collection: MediaCollection?
    let onSourceTapped: (Source) -> Void
    let onClipTapped: (Clip) -> Void
    
    static func topLevelItems(for collection: MediaCollection?) -> [TopLevelSourceItem] {
        guard let collection else { return [] }
        
        var items: [TopLevelSourceItem] = []
        let sources = collection.sources
        
        // 1. Groups
        let groups = collection.sourceGroups.map { group in
            TopLevelSourceGroup(
                sourceGroup: group,
                sources: sources
                    .filter { $0.sourceGroup == group }
                    .map { TopLevelSource(source: $0) }
                    .sorted { $0.sortOrder < $1.sortOrder }
            )
        }
        items += groups.map { .group($0) }
        
        // 2. Ungrouped sources
        let ungrouped = sources
            .filter { $0.sourceGroup == nil }
            .map { TopLevelSource(source: $0) }
        
        items += ungrouped.map { .source($0) }
        
        return items.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        List {
            ForEach(Self.topLevelItems(for: collection)) { item in
                switch item {
                case .group(let wrapper):
                    GroupSection(
                        wrapper: wrapper,
                        onSourceTapped: onSourceTapped,
                        onClipTapped: onClipTapped,
                        appRootManager: appRootManager
                    )
                    
                case .source(let wrapper):
                    SourceSection(
                        wrapper: wrapper,
                        onSourceTapped: onSourceTapped,
                        onClipTapped: onClipTapped,
                        appRootManager: appRootManager
                    )
                }
            }
        }
        .listStyle(.sidebar)
    }
}
//#Preview {
//    SourcesList()
//}
