//
//  PlaylistPickerGroupSection.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/9/26.
//

import SwiftData
import SwiftUI

struct PlaylistPickerGroupSection: View {
    let wrapper: TopLevelSourceGroup
    @Binding var selectedSourceIds: Set<PersistentIdentifier>
    @Binding var selectedClipIds: Set<PersistentIdentifier>

    var body: some View {

        DisclosureGroup(
            isExpanded: Binding(
                get: { wrapper.isExpanded },
                set: { wrapper.isExpanded = $0 }
            )
        ) {
            ForEach(wrapper.sources) { source in

                PlaylistPickerSourceSection(
                    wrapper: source,
                    selectedSourceIds: $selectedSourceIds,
                    selectedClipIds: $selectedClipIds
                )
            }

        } label: {

            Text(wrapper.sourceGroup.primitiveName)
                .font(.headline)
        }
        .padding(.leading, 24)
    }
}

//#Preview {
//    PlaylistPickerGroupSection()
//}
