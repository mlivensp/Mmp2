//  ClipEditView.swift
//  Mmp2
//
//  Created by Assistant

import SwiftData
import SwiftUI

struct ClipEditForm: View {
    @Environment(AppRootManager.self) private var appRootManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var vm: ClipEditView.ViewModel
    
    init(clip: Clip, source: Source, context: ModelContext) {
        _vm = State(initialValue: ClipEditView.ViewModel(clip: clip, source: source, context: context))
    }
    
    var body: some View {
        ScrollView {
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

                ErrorFieldContainer(
                    hasError: vm.bpmError != nil,
                    errorMessage: vm.bpmError
                ) {
                    HStack {
                        Text("BPM")
                        TextField("", text: $vm.bpmString)
                    }
                }

                ErrorFieldContainer(
                    hasError: false,
                    errorMessage: ""
                ) {
                    HStack {
                        Text("Measure Mode")
                        Toggle(isOn: $vm.measureMode) {
                            Text("Measure Mode")
                        }
                    }
                }

                if vm.measureMode == false {
                    ErrorFieldContainer(
                        hasError: vm.startSecondsError != nil,
                        errorMessage: vm.startSecondsError
                    ) {
                        HStack {
                            Text("Start")
                            TextField("", text: $vm.startTimeString)
                        }
                    }

                    ErrorFieldContainer(
                        hasError: vm.endSecondsError != nil,
                        errorMessage: vm.endSecondsError
                    ) {
                        HStack {
                            Text("End")
                            TextField("", text: $vm.endTimeString)
                        }
                    }
                } else {
                    ErrorFieldContainer(
                        hasError: vm.firstMeasureError != nil,
                        errorMessage: vm.firstMeasureError
                    ) {
                        HStack {
                            Text("First Measure")
                            TextField("", text: $vm.startMeasureString)
                                .frame(maxWidth: 60)
                        }
                    }

                    ErrorFieldContainer(
                        hasError: vm.lastMeasureError != nil,
                        errorMessage: vm.lastMeasureError
                    ) {
                        HStack {
                            Text("Last Measure")
                            TextField("", text: $vm.endMeasureString)
                                .frame(maxWidth: 60)
                        }
                    }
                }
                
                ErrorFieldContainer(
                    hasError: false,
                    errorMessage: ""
                ) {
                    HStack {
                        Text("Favorite")
                        Toggle(isOn: $vm.isFavorite) {
                            Text("Favorite")
                        }
                    }
                }
                
                ErrorFieldContainer(hasError: false, errorMessage: "") {
                    HStack {
                        Text("Notes")
                        TextField("", text: $vm.notes)
                    }
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
            .padding(formPadding)
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
