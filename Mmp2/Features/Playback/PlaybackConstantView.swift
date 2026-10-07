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
            ErrorFieldContainer(
                hasError: vm.rateError != nil,
                errorMessage: vm.rateError
            ) {
                HStack {
                    Text("Rate")
                    TextField("", text: $vm.rateString)
                        .frame(width: numericFieldWidth)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            ErrorFieldContainer(
                hasError: vm.timesToPlayError != nil,
                errorMessage: vm.timesToPlayError
            ) {
                HStack {
                    Text("Times To Play")
                    TextField("", text: $vm.timesToPlayString)
                        .frame(width: numericFieldWidth)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

//#Preview {
//    PlaybackConstantView()
//}
