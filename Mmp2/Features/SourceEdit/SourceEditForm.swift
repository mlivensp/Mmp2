//
//  SourceEditForm.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/5/26.
//

import SwiftData
import SwiftUI

struct SourceEditForm: View {
    @Environment(AppRootManager.self) private var appRootManager
    
    @State private var vm: SourceEditView.ViewModel
    
    init(source: Source, collection: MediaCollection, context: ModelContext) {
        _vm = State(initialValue: SourceEditView.ViewModel(source: source, collection: collection, context: context))
    }
    
    var body: some View {
        ScrollView {
            Form {
                Section("Name") {
                    ErrorFieldContainer(
                        hasError: vm.nameError != nil,
                        errorMessage: vm.nameError
                    ) {
                        TextField("", text: $vm.name)
                    }
                }
                
                Section("BPM") {
                    ErrorFieldContainer(
                        hasError: vm.bpmError != nil,
                        errorMessage: vm.bpmError
                    ) {
                        TextField("", text: $vm.bpmString)
                            .frame(maxWidth: 60)
                    }
                }
                
                Section("Sort Order") {
                    ErrorFieldContainer(
                        hasError: vm.sortOrderError != nil,
                        errorMessage: vm.sortOrderError
                    ) {
                        TextField("", text: $vm.sortOrderString)
                            .frame(maxWidth: 60)
                    }
                }
                
                Section("Measure 1 Start") {
                    ErrorFieldContainer(
                        hasError: vm.measure1StartError != nil,
                        errorMessage: vm.measure1StartError
                    ) {
                        TextField("", text: $vm.measure1StartString)
                            .frame(maxWidth: 100)
                    }
                }
                
                Toggle(isOn: $vm.isFavorite) {
                    Text("Favorite")
                }
                
                Section("Group") {
                    Picker("", selection: $vm.sourceGroup) {
                        Text("None").tag(nil as SourceGroup?)
                        
                        ForEach(vm.sourceGroups) { sourceGroup in
                            Text(sourceGroup.primitiveName)
                                .tag(sourceGroup)
                        }
                    }
                    .pickerStyle(.menu)   // This makes it behave like a dropdown
                }
                
                Section("Or New Group") {
                    TextField("", text: $vm.sourceGroupString)
                }
                
                Section("Notes") {
                    TextField("", text: $vm.notes)
                }
                
                Section {
                    PlaybackEditView(vm: vm.playbackVM)
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button("Save") {
                            do {
                                if try vm.save() {
                                    appRootManager.selectedCategory = .collections
                                }
                            } catch {
                                let _ = print(error.localizedDescription)
                                // TODO: notify user
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer()
                        
                        Button("Cancel") {
                            appRootManager.selectedCategory = .collections
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
            .scrollContentBackground(.hidden)   // optional, but recommended
            .padding(formPadding)
        }
    }
}

//#Preview {
//    SourceEditForm()
//}
