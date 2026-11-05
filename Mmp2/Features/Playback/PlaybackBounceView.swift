//
//  PlaybackBounceView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/5/26.
//

import SwiftData
import SwiftUI

struct PlaybackBounceView: View {
    @Bindable var vm: PlaybackBounceViewModel
    @Query(sort: \PlayOrder.sortOrder) private var playOrders: [PlayOrder]

    var body: some View {
        Group {
            ErrorFieldContainer(
                hasError: vm.slowError != nil,
                errorMessage: vm.slowError
            ) {
                HStack {
                    Text("Slow")
                    TextField("", text: $vm.slowString)
                        .frame(maxWidth: 60)
                }
            }

            ErrorFieldContainer(
                hasError: vm.slowTimesToPlayError != nil,
                errorMessage: vm.slowTimesToPlayError
            ) {
                HStack {
                    Text("Slow Times To Play")
                    TextField("", text: $vm.slowTimesToPlayString)
                        .frame(maxWidth: 60)
                }
            }

            ErrorFieldContainer(
                hasError: vm.midError != nil,
                errorMessage: vm.midError
            ) {
                HStack {
                    Text("Mid")
                    TextField("", text: $vm.midString)
                        .frame(maxWidth: 60)
                }
            }

            ErrorFieldContainer(
                hasError: vm.midTimesToPlayError != nil,
                errorMessage: vm.midTimesToPlayError
            ) {
                HStack {
                    Text("Mid Times To Play")
                    TextField("", text: $vm.midTimesToPlayString)
                        .frame(maxWidth: 60)
                }
            }

            ErrorFieldContainer(
                hasError: vm.fastError != nil,
                errorMessage: vm.fastError
            ) {
                HStack {
                    Text("Fast ")
                    TextField("", text: $vm.fastString)
                        .frame(maxWidth: 60)
                }
            }

            ErrorFieldContainer(
                hasError: vm.fastTimesToPlayError != nil,
                errorMessage: vm.fastTimesToPlayError
            ) {
                HStack {
                    Text("Fast Times To Play")
                    TextField("", text: $vm.fastTimesToPlayString)
                        .frame(maxWidth: 60)
                }
            }

            ErrorFieldContainer(
                hasError: vm.playOrderError != nil,
                errorMessage: vm.playOrderError
            ) {
                HStack {
                    Text("Play Order")
                    Picker("", selection: $vm.playOrder) {
                        Text("Select a play order").tag(nil as PlayOrder?)
                        
                        ForEach(playOrders) { playOrder in
                            Text(playOrder.name)
                                .tag(playOrder)
                        }
                    }
                    .pickerStyle(.menu)   // This makes it behave like a dropdown
                }
            }
        }
    }
}

//#Preview {
//    PlaybackBounceView()
//}
