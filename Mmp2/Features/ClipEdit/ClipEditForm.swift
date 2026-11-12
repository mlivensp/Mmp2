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
                            .frame(width: numericFieldWidth)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                ErrorFieldContainer(
                    hasError: false,
                    errorMessage: ""
                ) {
                    HStack {
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
                                .frame(width: timespanFieldWidth)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    ErrorFieldContainer(
                        hasError: vm.endSecondsError != nil,
                        errorMessage: vm.endSecondsError
                    ) {
                        HStack {
                            Text("End")
                            TextField("", text: $vm.endTimeString)
                                .frame(width: timespanFieldWidth)
                                .multilineTextAlignment(.trailing)
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
                                .frame(width: numericFieldWidth)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    ErrorFieldContainer(
                        hasError: vm.lastMeasureError != nil,
                        errorMessage: vm.lastMeasureError
                    ) {
                        HStack {
                            Text("Last Measure")
                            TextField("", text: $vm.endMeasureString)
                                .frame(width: numericFieldWidth)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                
                ErrorFieldContainer(
                    hasError: false,
                    errorMessage: ""
                ) {
                    HStack {
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
                
                Text("Playback")
                    .font(.headline)
                
                PlaybackEditView(vm: vm.playbackVM)

                Section {
                    HStack {
                        Spacer()
                        
                        Button("Cancel") {
                            exit()
                        }
                        .foregroundColor(.secondary)

                        Button("Done") {
                            do {
                                if try vm.save() {
                                    exit()
                                }
                            } catch {
                                let _ = print(error.localizedDescription)
                                // TODO: notify user
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
    /// Leaves the editor, whichever way we got here.
    private func exit() {
        if appRootManager.currentRoot == .clipEdit {
            // Came from SinglePlayerView: go back to the player.
            appRootManager.editingClip = nil
            appRootManager.currentRoot = .play
        } else {
            // Came from the sources list in .home.
            appRootManager.selectedCategory = .collections
            dismiss() // keep this if you were already calling it there
        }
    }
}

#if DEBUG
//#Preview {
//    // Dummy clip for preview
//    let dummyPlayback = Playback(timesToPlay: 1)
//    let dummyClip = Clip(source: nil, name: "Sample Clip", startSeconds: 10, endSeconds: 20, startMeasure: 1, endMeasure: 4, isFavorite: false, notes: "Sample", playback: dummyPlayback)
//    
//    let dummySourcePlayback = Playback(timesToPlay: 1)
//    let dummySource = Source(name: "Sample Source", sortOrder: 0, measure1Start: nil, isFavorite: false, isExpanded: false, notes: nil, playback: dummySourcePlayback, sourceGroup: nil)
//    return ClipEditView(clip: dummyClip, source: dummySource)
//}
#endif
