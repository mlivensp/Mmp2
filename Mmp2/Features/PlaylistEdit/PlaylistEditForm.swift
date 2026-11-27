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
            HStack(alignment: .top) {
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
            .frame(maxWidth: .infinity, maxHeight: 150)

            Text("Media To Play")
                .font(.headline)
                .frame(minWidth: 50, alignment: .leading)
            
            Divider()
            
            HStack(spacing: 0) {
                ScrollView {
                    let playlistItems = vm.playlistItems
                        .sorted { $0.sortOrder < $1.sortOrder }
                    ForEach(playlistItems) { playlistItem in
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
                        Spacer()
                        Text("\(playlistItem.sortOrder)")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                
                toolbar
                    .frame(width: 20)
                    .padding([.leading, .trailing], formPadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.leading, .trailing], formPadding)
                        
            HStack {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
                
                Button("Done") {
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
        .sheet(isPresented: $showingAddItemSheet) {
            PlaylistItemPickerSheet(playlistVM: vm)
        }
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
                
                if let index = vm.playlistItems.firstIndex(where: { $0.id == row.id }) {
                    vm.playlistItems.remove(at: index)
                }
            } label: {
                Image(systemName: "trash")
            }
            .disabled(selectedPlaylistItem == nil)
            
            Divider()
            
            Button {
                guard let row = selectedPlaylistItem else {
                    return
                }
                
                vm.moveItemUp(row)
                
            } label: {
                Image(systemName: "arrow.up")
            }
            .disabled(
                selectedPlaylistItem == nil
                || selectedPlaylistItem?.playlistItem == vm.playlistItems.first?.playlistItem
            )
            
            Button {
                guard let row = selectedPlaylistItem else {
                    return
                }
                
                vm.moveItemDown(row)
                
            } label: {
                Image(systemName: "arrow.down")
            }
            .disabled(
                selectedPlaylistItem == nil
                || selectedPlaylistItem?.playlistItem == vm.playlistItems.last?.playlistItem
            )
            
            Spacer()
        }
        .padding()
    }
}

//#Preview {
//    PlaylistEditForm()
//}
