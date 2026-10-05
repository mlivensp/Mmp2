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
        Section("Playback Mode") {
            Picker("", selection: $vm.mode) {
                ForEach(PlaybackMode.allCases) { mode in
                    Text(mode.label)
                }
            }
            .pickerStyle(.menu)   // This makes it behave like a dropdown
            
            switch vm.mode {
            case .constant:
                PlaybackConstantView(vm: vm.constantVM)
            case .stepwise:
                PlaybackStepwiseView(vm: vm.stepwiseVM)
            case .bounce:
                PlaybackBounceView(vm: vm.bounceVM)
            }
        }
    }
}

//#Preview {
//    PlaybackEditView()
//}
