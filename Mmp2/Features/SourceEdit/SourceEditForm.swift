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
    @Environment(\.dismiss) private var dismiss
    
    @State private var vm: SourceEditView.ViewModel
    
    init(source: Source, collection: MediaCollection, context: ModelContext) {
        _vm = State(initialValue: SourceEditView.ViewModel(source: source, collection: collection, context: context))
    }
    
    var body: some View {
        ScrollView {
            Text("Source")
                .font(.title)
            Form {
                HStack {
                    Button {
                        print("pick location")
                    } label: {
                        Text("Browse")
                    }
                    .buttonStyle(.borderedProminent)
                    TextEditor(text: $vm.mediaPath)   // wraps + grows
                        .disabled(true)        // if you want it read-only
                }
//
                
                ErrorFieldContainer(
                    hasError: vm.nameError != nil,
                    errorMessage: vm.nameError
                ) {
                    HStack {
                        Text("Name")
                    TextField("", text: $vm.name)
                    }
                }
                
                ErrorFieldContainer(
                    hasError: vm.bpmError != nil,
                    errorMessage: vm.bpmError
                ) {
                    HStack {
                        Text("BPM")
                        TextField("", text: $vm.bpmString)
                            .frame(width: numericFieldWidth)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                ErrorFieldContainer(
                    hasError: vm.sortOrderError != nil,
                    errorMessage: vm.sortOrderError
                ) {
                    HStack {
                        Text("Sort Order")
                        TextField("", text: $vm.sortOrderString)
                            .frame(width: numericFieldWidth)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                ErrorFieldContainer(
                    hasError: vm.measure1StartError != nil,
                    errorMessage: vm.measure1StartError
                ) {
                    HStack {
                        Text("Measure 1 Start")
                        TextField("", text: $vm.measure1StartString)
                            .frame(width: 200)
                    }
                }
                
                Toggle(isOn: $vm.isFavorite) {
                    Text("Favorite")
                }

                HStack {
                    Text("Group")
                    Picker("", selection: $vm.sourceGroup) {
                        Text("None").tag(nil as SourceGroup?)
                        
                        ForEach(vm.sourceGroups) { sourceGroup in
                            Text(sourceGroup.primitiveName)
                                .tag(sourceGroup)
                        }
                    }
                    .pickerStyle(.menu)   // This makes it behave like a dropdown
                }
                
                HStack {
                    Text("Or New Group")
                    TextField("", text: $vm.sourceGroupString)
                }
                
                HStack {
                    Text("Notes")
                    TextField("", text: $vm.notes)
                }
                
                Section("Playback") {
                    PlaybackEditView(vm: vm.playbackVM)
                }
                
                Section {
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
