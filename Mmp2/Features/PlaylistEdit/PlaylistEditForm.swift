//
//  PlaylistEditForm.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/7/26.
//

import SwiftData
import SwiftUI

struct PlaylistEditForm: View {
    @Environment(AppRootManager.self) private var appRootManager
    @Environment(\.dismiss) private var dismiss
    
    @State var vm: PlaylistEditView.ViewModel
    
    @State private var selectedPlaylistItem: PlaylistItemViewModel?
    @State private var selectedPlaylistGroupItem: PlaylistGroupItem?
    @State private var showingAddItemSheet = false
    @State private var showingAddGroupSheet = false
    @State private var showingDeleteMembershipConfirmation = false
    
    init(playlist: Playlist, context: ModelContext) {
        _vm = State(initialValue: PlaylistEditView.ViewModel(playlist: playlist, context: context))
    }
    
    var body: some View {
        VStack {
            HStack {
                Form {
                    ErrorFieldContainer(
                        hasError: vm.nameError != nil,
                        errorMessage: vm.nameError
                    ) {
                        HStack {
                            Text("Name")
                            TextField("", text: $vm.name)
                        }
                    }
                    
                    Toggle(isOn: $vm.shuffle) {
                        Text("Shuffle")
                    }
                    
                    ErrorFieldContainer(
                        hasError: vm.defaultDelayError != nil,
                        errorMessage: vm.defaultDelayError
                    ) {
                        HStack {
                            Text("Default Delay (seconds)")
                            TextField("", text: $vm.defaultDelayString)
                        }
                    }
                    
                    ErrorFieldContainer(
                        hasError: vm.timesToRepeatError != nil,
                        errorMessage: vm.timesToRepeatError
                    ) {
                        HStack {
                            Text("Times To Repeat")
                            TextField("", text: $vm.timesToRepeatString)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    HStack {
                        Text("In Groups")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            showingAddGroupSheet = true
                        } label: {
                            Label("", systemImage: "plus")
                        }
                        .buttonStyle(.automatic)
                        .sheet(isPresented: $showingAddGroupSheet) {
                            PlaylistGroupPickerSheet(
                                playlist: vm.playlist,
                                context: vm.context
                            )
                        }
                        
                        Button {
                            showingDeleteMembershipConfirmation = true
                        } label: {
                            Label("", systemImage: "trash")
                        }
                        .buttonStyle(.automatic)
                        .disabled(selectedPlaylistGroupItem == nil)
                        .alert(
                            "Remove Group Membership",
                            isPresented: $showingDeleteMembershipConfirmation
                        ) {
                            Button("Delete", role: .destructive) {
                                if let selectedPlaylistGroupItem {
                                    vm.removeGroupMembership(selectedPlaylistGroupItem)
                                    self.selectedPlaylistGroupItem = nil
                                }
                            }
                            
                            Button("Cancel", role: .cancel) {
                            }
                        } message: {
                            if let selectedPlaylistGroupItem {
                                Text(
                                    "Remove this playlist from '\(selectedPlaylistGroupItem.playlistGroup.primitiveName)'?"
                                )
                            }
                        }
                    }
                    
                    Divider()
                    
                    ScrollView {
                        ForEach(vm.groupItems) { groupItem in
                            Text(groupItem.playlistGroup.primitiveName)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(4)
                                .background(
                                    selectedPlaylistGroupItem?.id == groupItem.id
                                    ? Color.accentColor.opacity(0.2)
                                    : Color.clear
                                )
                                .onTapGesture {
                                    selectedPlaylistGroupItem = groupItem
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
            
            Text("Media To Play")
                .font(.headline)
                .frame(minWidth: 50, alignment: .leading)

            Divider()
            
            HStack(spacing: 0) {
                ScrollView {
                    ForEach(vm.playlistItems) { playlistItem in
                        Text(playlistItem.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(4)
                            .background(
                                selectedPlaylistItem?.id == playlistItem.id
                                ? Color.accentColor.opacity(0.2)
                                : Color.clear
                            )
                            .onTapGesture {
                                selectedPlaylistItem = playlistItem
                            }
                    }
                }
                .frame(maxHeight: .infinity)
                
                Divider()
                
                toolbar
                    .frame(width: 30)
                    .padding([.leading, .trailing], formPadding)
            }
            .padding([.leading, .trailing], formPadding)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
                
                Button("Save") {
                    do {
                        if try vm.save() {
                            dismiss()
                        }
                    } catch {
                        let _ = print(error.localizedDescription)
                        // TODO: notify user
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .padding([.leading, .trailing], formPadding)
    }
    
    private func addPlaylistItem() {
        
    }
}

private extension PlaylistEditForm {
    
    var toolbar: some View {
        
        VStack(spacing: 8) {
            
            Button {
                showingAddItemSheet = true
            } label: {
                Image(systemName: "plus")
            }
            
            Button {
                guard let row = selectedPlaylistItem else {
                    return
                }
                
                // TODO: delete playlist item
                //                self.selectedRow = vm.delete(row: row)
                
            } label: {
                Image(systemName: "trash")
            }
            .disabled(selectedPlaylistItem == nil)
            
            Divider()
            
            Button {
                guard let row = selectedPlaylistItem else {
                    return
                }
                
                // TODO: playlist item move up
                //                vm.moveUp(row)
                
            } label: {
                Image(systemName: "arrow.up")
            }
            .disabled(
                selectedPlaylistItem == nil
                // TODO: disable if first item
                // || selectedPlaylistItem == vm.playlistItems.first
            )
            
            Button {
                guard let row = selectedPlaylistItem else {
                    return
                }
                
                // TODO: playlist item move down
                //                vm.moveDown(row)
                
            } label: {
                Image(systemName: "arrow.down")
            }
            .disabled(
                selectedPlaylistItem == nil
                // TODO: disable if lat item
                //                || selectedRow == vm.topLevelRows.last
            )
            
            Spacer()
        }
        .padding()
    }
}

//#Preview {
//    PlaylistEditForm()
//}
