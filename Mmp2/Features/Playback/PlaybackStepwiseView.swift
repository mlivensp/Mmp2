//
//  PlaybackStepwiseView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/5/26.
//

import SwiftUI

struct PlaybackStepwiseView: View {
    @Bindable var vm: PlaybackStepwiseViewModel
    var isBPM: Bool
    
    var body: some View {
        Group {
            ErrorFieldContainer(
                hasError: vm.startError != nil,
                errorMessage: vm.startError
            ) {
                HStack {
                    Text(isBPM ? "Starting BPM" : "Starting % of Speed")
                    TextField("", text: $vm.startString)
                        .frame(maxWidth: 60)
                }
            }
            
            ErrorFieldContainer(
                hasError: vm.stepError != nil,
                errorMessage: vm.stepError
            ) {
                HStack {
                    Text("Step")
                    TextField("", text: $vm.stepString)
                        .frame(maxWidth: 60)
                }
            }
            
            ErrorFieldContainer(
                hasError: vm.maxError != nil,
                errorMessage: vm.maxError
            ) {
                HStack {
                    Text("Max")
                    TextField("", text: $vm.maxString)
                        .frame(maxWidth: 60)
                }
            }
            
            ErrorFieldContainer(
                hasError: vm.timesToPlayError != nil,
                errorMessage: vm.timesToPlayError
            ) {
                HStack {
                    Text("Times To Play Each Tempo")
                        .frame(maxWidth: 100)
                    TextField("", text: $vm.timesToPlayString)
                        .frame(maxWidth: 60)
                }
            }
        }
    }
}

//#Preview {
//    PlaybackStepwiseView()
//}
