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
    
    private var topLevelItems: [TopLevelItem] {
        guard let collection else { return [] }
        
        var items: [TopLevelItem] = []
        
        // 1. Groups
        let groups = collection.sourceGroups.map {
            TopLevelSourceGroup(
                sourceGroup: $0,
                sources: topLevelSources($0.sources)
            )
        }
        items += groups.map { .group($0) }
        
        // 2. Ungrouped sources
        let ungrouped = collection.sources
            .filter { $0.sourceGroup == nil }
            .map { TopLevelSource(source: $0) }
        
        items += ungrouped.map { .source($0) }
        
        return items.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private func topLevelSources(_ sources: [Source]) -> [TopLevelSource] {
        sources.map { TopLevelSource(source: $0) }
            .sorted(by: { $0.sortOrder  < $1.sortOrder })
    }
    
    var body: some View {
        List {
            ForEach(topLevelItems) { item in
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
