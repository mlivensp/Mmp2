//
//  PlaylistPickerSourceSection.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/9/26.
//

import SwiftData
import SwiftUI

struct PlaylistPickerSourceSection: View {
    let wrapper: TopLevelSource
    @Binding var selectedSourceIds: Set<PersistentIdentifier>
    @Binding var selectedClipIds: Set<PersistentIdentifier>

    var body: some View {

        DisclosureGroup(
            isExpanded: Binding(
                get: { wrapper.isExpanded },
                set: { wrapper.isExpanded = $0 }
            )
        ) {

            ForEach(wrapper.source.clips) { clip in

                HStack {

                    SelectionIndicator(
                        isSelected: selectedClipIds.contains(
                            clip.persistentModelID
                        )
                    )

                    Text(clip.primitiveName)
                }
                .contentShape(Rectangle())
                .padding(.leading, 42)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {

                    let id = clip.persistentModelID

                    if selectedClipIds.contains(id) {
                        selectedClipIds.remove(id)
                    } else {
                        selectedClipIds.insert(id)
                    }
                }
            }

        } label: {
            
            HStack {

                SelectionIndicator(
                    isSelected: selectedSourceIds.contains(
                        wrapper.source.persistentModelID
                    )
                )

                Text(wrapper.source.primitiveName)
            }
            .contentShape(Rectangle())
            .padding(.leading, 12)
            .onTapGesture {

                let id = wrapper.source.persistentModelID

                if selectedSourceIds.contains(id) {
                    selectedSourceIds.remove(id)
                } else {
                    selectedSourceIds.insert(id)
                }
            }
        }
    }
}

//#Preview {
//    PlaylistPickerSourceSection()
//}
