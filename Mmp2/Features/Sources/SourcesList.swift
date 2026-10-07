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
    
    // Combined list of top-level items
    private var topLevelItems: [TopLevelItem] {
        var items: [TopLevelItem] = []
        
        // 1. Source Groups (sorted)
        let groups = (collection?.sourceGroups ?? [])
            .sorted { $0.sortOrder < $1.sortOrder }   // or by name if you prefer
        items += groups.map { .group($0) }
        
        // 2. Ungrouped sources
        let ungrouped = (collection?.sources ?? [])
            .filter { $0.sourceGroup == nil }
            .sorted { ($0.sortOrder) < ($1.sortOrder) }
        
        items += ungrouped.map { .source($0) }
        
        return items.sorted(by: { $0.sortOrder < $1.sortOrder } )
    }
    
    var body: some View {
        List {
            ForEach(topLevelItems) { item in
                switch item {
                case .group(let group):
                    DisclosureGroup {
                        // Sources inside the group
                        let sortedSources = group.sources.sorted(by: { $0.sortOrder < $1.sortOrder })
                        ForEach(sortedSources) { source in
                            if source.clips.isEmpty {
                                SourceRow(source: source) { source in
                                    // TODO: think about how to get rid of force unwrap
                                    // probably mediaCollection is not optional on source
                                    appRootManager.editSource(source, in: source.mediaCollection!)
                                }
                                .onTapGesture {
                                    onSourceTapped(source)
                                }
                            } else {
                                DisclosureGroup {
                                    let sortedClips = source.clips.sorted(by: {
                                        if $0.startSeconds == $1.startSeconds {
                                            return $0.endSeconds < $1.endSeconds
                                        } else {
                                            return $0.startSeconds < $1.startSeconds
                                        }
                                    })
                                    ForEach(sortedClips) { clip in
                                        ClipRow(clip: clip) { clip in
                                            appRootManager.editClip(clip, of: source)
                                        }
                                        .onTapGesture {
                                            onClipTapped(clip)
                                        }
                                    }
                                } label: {
                                    SourceRow(source: source) { source in
                                        appRootManager.editSource(source, in: source.mediaCollection!)
                                    }
                                    .onTapGesture {
                                        onSourceTapped(source)
                                    }
                                }
                            }
                        }
                    } label: {
                        Label(group.primitiveName, systemImage: "music.note.square.stack")
                    }
                    
                case .source(let source):
                    if !source.clips.isEmpty {
                        DisclosureGroup {
                            let sortedClips = source.clips.sorted(by: {
                                if $0.startSeconds == $1.startSeconds {
                                    return $0.endSeconds < $1.endSeconds
                                } else {
                                    return $0.startSeconds < $1.startSeconds
                                }
                            })
                            ForEach(sortedClips) { clip in
                                ClipRow(clip: clip) { clip in
                                    appRootManager.editClip(clip, of: source)
                                }
                                .onTapGesture {
                                    onClipTapped(clip)
                                }
                            }
                        } label: {
                            SourceRow(source: source) { source in
                                appRootManager.editSource(source, in: source.mediaCollection!)
                            }
                            .onTapGesture {
                                onSourceTapped(source)
                            }
                        }
                    } else {
                        SourceRow(source: source) { source in
                            appRootManager.editSource(source, in: source.mediaCollection!)
                        }
                        .onTapGesture {
                            onSourceTapped(source)
                        }
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
