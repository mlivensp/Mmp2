//
//  PlaybackEditView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import SwiftUI

struct PlaybackEditView: View {
    @Bindable var vm: PlaybackEditViewModel
    
    var body: some View {
        Picker("Mode", selection: $vm.mode) {
            ForEach(PlaybackMode.allCases) { mode in
                Text(mode.label)
                    .tag(mode)
            }
        }
        .pickerStyle(.menu)   // This makes it behave like a dropdown
        
        ErrorFieldContainer(
            hasError: vm.timesToPlayError != nil,
            errorMessage: vm.timesToPlayError
        ) {
            HStack {
                Text("Times To Repeat")
                TextField("", text: $vm.timesToPlayString, prompt: Text("∞"))
                    .frame(maxWidth: 60)
            }
        }

        switch vm.mode {
        case .constant:
            PlaybackConstantView(vm: vm.constantVM, isBPM: vm.bpm != nil)
        case .stepwise:
            PlaybackStepwiseView(vm: vm.stepwiseVM, isBPM: vm.bpm != nil)
        case .bounce:
            PlaybackBounceView(vm: vm.bounceVM)
        }
    }
}

//#Preview {
//    PlaybackEditView()
//}
