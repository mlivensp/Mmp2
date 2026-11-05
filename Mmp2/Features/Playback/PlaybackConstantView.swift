//
//  PlaybackConstantView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/5/26.
//

import SwiftUI

struct PlaybackConstantView: View {
    @Bindable var vm: PlaybackConstantViewModel
    var isBPM: Bool
    
    var body: some View {
        Group {
            ErrorFieldContainer(
                hasError: vm.rateError != nil,
                errorMessage: vm.rateError
            ) {
                HStack {
                    Text(isBPM ? "BPM" : "% of Speed")
                    TextField("", text: $vm.rateString)
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
