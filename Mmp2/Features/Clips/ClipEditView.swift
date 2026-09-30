//  ClipEditView.swift
//  Mmp2
//
//  Created by Assistant

import SwiftUI

struct ClipEditView: View {
    @Environment(AppRootManager.self) private var appRootManager
    @Environment(\.dismiss) private var dismiss

    @State private var vm: ViewModel

    init(clip: Clip, source: Source) {
        _vm = State(initialValue: ViewModel(clip: clip, source: source))
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
                            hasError: vm.startMeasureError != nil,
                            errorMessage: vm.startMeasureError
                        ) {
                            TextField("", text: $vm.startMeasureString)
                        }
                    }
                    
                    Section("Last Measure") {
                        ErrorFieldContainer(
                            hasError: vm.endMeasureError != nil,
                            errorMessage: vm.endMeasureError
                        ) {
                            TextField("", text: $vm.endMeasureString)
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
                            if vm.save() {
                                appRootManager.selectedCategory = .collections
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
