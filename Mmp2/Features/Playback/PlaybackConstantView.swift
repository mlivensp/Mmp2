//
//  PlaybackConstantView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/5/26.
//

import SwiftUI

struct PlaybackConstantView: View {
    @Bindable var vm: PlaybackConstantViewModel
    
    var body: some View {
        Group {
            Section("Rate") {
                ErrorFieldContainer(
                    hasError: vm.rateError != nil,
                    errorMessage: vm.rateError
                ) {
                    TextField("", text: $vm.rateString)
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
//    PlaybackConstantView()
//}
