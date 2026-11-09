//
//  PlaylistGroupPickerSheet.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/8/26.
//

import SwiftData
import SwiftUI

struct PlaylistGroupPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var vm: ViewModel
    
    init(
        playlist: Playlist,
        context: ModelContext
    ) {
        _vm = State(
            initialValue: ViewModel(
                playlist: playlist,
                context: context
            )
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Playlist Groups")
                .font(.headline)
            
            List(vm.groups) { group in
                Button {
                    vm.addPlaylistToGroup(group)
                } label: {
                    HStack {
                        Text(group.primitiveName)
                            .foregroundStyle(
                                vm.isAlreadyInGroup(group)
                                ? .secondary
                                : .primary
                            )
                        
                        Spacer()
                        
                        if vm.isAlreadyInGroup(group) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            Text("Create New Group")
                .font(.headline)
            
            
            HStack {
                TextField(
                    "Group Name",
                    text: $vm.newGroupName
                )
                .textFieldStyle(.roundedBorder)
                
                Spacer()
                
                Button("Create") {
                    vm.createGroup()
                    dismiss()
                }
                .disabled(
                    vm.newGroupName.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty
                )
            }
            
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 500)
    }
}

//#Preview {
//    PlaylistGroupPickerSheet()
//}
