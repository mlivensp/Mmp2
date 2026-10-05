//
//  PlaybackStepwiseView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/5/26.
//

import SwiftUI

struct PlaybackStepwiseView: View {
    @Bindable var vm: PlaybackStepwiseViewModel
    
    var body: some View {
        Group {
            Section("Start") {
                ErrorFieldContainer(
                    hasError: vm.startError != nil,
                    errorMessage: vm.startError
                ) {
                    TextField("", text: $vm.startString)
                        .frame(maxWidth: 60)
                }
            }
            
            Section("Step") {
                ErrorFieldContainer(
                    hasError: vm.stepError != nil,
                    errorMessage: vm.stepError
                ) {
                    TextField("", text: $vm.stepString)
                        .frame(maxWidth: 60)
                }
            }
            
            Section("Max") {
                ErrorFieldContainer(
                    hasError: vm.maxError != nil,
                    errorMessage: vm.maxError
                ) {
                    TextField("", text: $vm.maxString)
                        .frame(maxWidth: 60)
                }
            }
            
            Section("Times To Play") {
                ErrorFieldContainer(
                    hasError: vm.timesToPlayError != nil,
                    errorMessage: vm.timesToPlayError
                ) {
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
