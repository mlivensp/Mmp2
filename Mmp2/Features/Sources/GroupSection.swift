//
//  GroupSection.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/13/26.
//

import SwiftUI

struct GroupSection: View {
    let wrapper: TopLevelSourceGroup
    let onSourceTapped: (Source) -> Void
    let onClipTapped: (Clip) -> Void
    let appRootManager: AppRootManager
    
    var body: some View {
        DisclosureGroup(isExpanded: Binding(
            get: { wrapper.isExpanded },
            set: { wrapper.isExpanded = $0 }
        )) {
            ForEach(wrapper.sources) { sourceWrapper in
                SourceSection(
                    wrapper: sourceWrapper,
                    onSourceTapped: onSourceTapped,
                    onClipTapped: onClipTapped,
                    appRootManager: appRootManager
                )
            }
        } label: {
            Label(wrapper.sourceGroup.primitiveName,
                  systemImage: "music.note.square.stack")
        }
    }
}
