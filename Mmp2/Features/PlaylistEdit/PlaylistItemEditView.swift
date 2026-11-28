//
//  PlaylistItemEditView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/27/26.
//

import SwiftUI

struct PlaylistItemEditView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @Bindable var vm: PlaylistItemViewModel
    
    var body: some View {
        VStack {
            ErrorFieldContainer(
                hasError: vm.secondsToDelayError != nil,
                errorMessage: vm.secondsToDelayError
            ) {
                HStack {
                    Text("Seconds To Delay Override")
                TextField("", text: $vm.secondsToDelayString)
                        .frame(width: numericFieldWidth)
                }
            }

            Toggle("Use Custom Playback", isOn: $vm.useCustomPlayback)
            
            PlaybackEditView(vm: vm.playbackVM)
                .disabled(vm.useCustomPlayback == false)
            
            Divider()
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Done") {
                    do {
                        try vm.apply()
                    } catch {
                        // TODO: notify user
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .padding(formPadding)
    }
}

//#Preview {
//    PlaylistItemEditView()
//}
