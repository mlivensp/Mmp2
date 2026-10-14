//
//  SourceSection.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/13/26.
//

import SwiftUI

struct SourceSection: View {
    let wrapper: TopLevelSource
    let onSourceTapped: (Source) -> Void
    let onClipTapped: (Clip) -> Void
    let appRootManager: AppRootManager
    
    var body: some View {
        let source = wrapper.source
        
        if source.clips.isEmpty {
            SourceRow(source: source) { src in
                appRootManager.editSource(src, in: src.mediaCollection!)
            }
            .onTapGesture { onSourceTapped(source) }
            
        } else {
            DisclosureGroup(isExpanded: Binding(
                get: { wrapper.isExpanded },
                set: { wrapper.isExpanded = $0 }
            )) {
                ClipSection(
                    clips: source.clips,
                    source: source,
                    onClipTapped: onClipTapped,
                    appRootManager: appRootManager
                )
            } label: {
                SourceRow(source: source) { src in
                    appRootManager.editSource(src, in: src.mediaCollection!)
                }
                .onTapGesture { onSourceTapped(source) }
            }
        }
    }
}
