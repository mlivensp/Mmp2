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
            GeometryReader { proxy in
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
                        Spacer()
                    }
                    .frame(width: proxy.size.width / 2)
                    
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
                            }                       }
                        
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
                        
                        Divider()
                    }
                    .frame(width: proxy.size.width / 2)
                }
            }
            .padding([.leading, .trailing], formPadding)
            
            HStack {
                Text("Media To Play")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .trailing], formPadding)
                
                Button {
                    if let selectedPlaylistItem {
                        vm.moveItemUp(selectedPlaylistItem)
                    }
                } label: {
                    Image(systemName: "arrow.up")
                }
                .buttonStyle(.bordered)
                
                Button {
                    if let selectedPlaylistItem {
                        vm.moveItemDown(selectedPlaylistItem)
                    }
                } label: {
                    Image(systemName: "arrow.down")
                }
                .buttonStyle(.bordered)
                Spacer()
                
                Button {
                    showingAddItemSheet = true
                } label: {
                    Label("", systemImage: "plus")
                }
                .buttonStyle(.automatic)
                .sheet(isPresented: $showingAddItemSheet) {
                    PlaylistItemPickerSheet(playlist: vm.playlist)
                }
            }
            .padding([.leading, .trailing], formPadding)
            
            Divider()
            
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
            //            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.leading, .trailing], formPadding)
            
            Spacer()
            
            HStack {
                Spacer()
                
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
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func addPlaylistItem() {
        
    }
}

//#Preview {
//    PlaylistEditForm()
//}
