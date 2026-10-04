//  ClipEditView.swift
//  Mmp2
//
//  Created by Assistant

import SwiftData
import SwiftUI

struct ClipEditViewContent: View {
    @Environment(AppRootManager.self) private var appRootManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var vm: ViewModel
    
    init(clip: Clip, source: Source, context: ModelContext) {
        _vm = State(initialValue: ViewModel(clip: clip, source: source, context: context))
    }
    
    var body: some View {
        NavigationStack {
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
                    }
                }
                
                Toggle(isOn: $vm.measureMode) {
                    Text("Measure Mode")
                }
                
                if vm.measureMode == false {
                    Section("Start") {
                        ErrorFieldContainer(
                            hasError: vm.startSecondsError != nil,
                            errorMessage: vm.startSecondsError
                        ) {
                            TextField("", text: $vm.startTimeString)
                        }
                    }
                    
                    Section("End") {
                        ErrorFieldContainer(
                            hasError: vm.endSecondsError != nil,
                            errorMessage: vm.endSecondsError
                        ) {
                            TextField("", text: $vm.endTimeString)
                        }
                    }
                } else {
                    Section("First Measure") {
                        ErrorFieldContainer(
                            hasError: vm.firstMeasureError != nil,
                            errorMessage: vm.firstMeasureError
                        ) {
                            TextField("", text: $vm.startMeasureString)
                                .frame(maxWidth: 60)
                        }
                    }
                    
                    Section("Last Measure") {
                        ErrorFieldContainer(
                            hasError: vm.lastMeasureError != nil,
                            errorMessage: vm.lastMeasureError
                        ) {
                            TextField("", text: $vm.endMeasureString)
                                .frame(maxWidth: 60)
                        }
                    }
                }
                
                Section {
                    Toggle("Favorite", isOn: $vm.isFavorite)
                }
                
                Section("Notes") {
                    TextField("", text: $vm.notes)
                }
                
                //                if let error = vm.error {
                //                    Section {
                //                        Text(error).foregroundColor(.red)
                //                    }
                //                }
                
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
            .navigationTitle("Edit Clip")
        }
    }
}

#if DEBUG
#Preview {
    // Dummy clip for preview
    let dummyMedia = Media(bpm: 120, path: "", duration: 60)
    let dummyPlayback = Playback()
    let dummyClip = Clip(source: nil, name: "Sample Clip", startSeconds: 10, endSeconds: 20, startMeasure: 1, endMeasure: 4, isFavorite: false, notes: "Sample", media: dummyMedia, playback: dummyPlayback)
    
    let dummySourceMedia = Media(bpm: 90, path: "", duration: 62)
    let dummySourcePlayback = Playback()
    let dummySource = Source(name: "Sample Source", sortOrder: 0, measure1Start: nil, isFavorite: false, notes: nil, media: dummySourceMedia, playback: dummySourcePlayback, sourceGroup: nil)
    return ClipEditView(clip: dummyClip, source: dummySource)
}
#endif
