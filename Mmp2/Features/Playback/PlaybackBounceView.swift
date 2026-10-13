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
                hasError: vm.slowTempoError != nil,
                errorMessage: vm.slowTempoError
            ) {
                HStack {
                    Text("Slow Tempo")
                    TextField("", text: $vm.slowTempoString)
                        .frame(maxWidth: 60)
                }
            }

            ErrorFieldContainer(
                hasError: vm.slowTempoTimesToPlayError != nil,
                errorMessage: vm.slowTempoTimesToPlayError
            ) {
                HStack {
                    Text("Slow Tempo Times To Play")
                    TextField("", text: $vm.slowTempoTimesToPlayString)
                        .frame(maxWidth: 60)
                }
            }

            ErrorFieldContainer(
                hasError: vm.midTempoError != nil,
                errorMessage: vm.midTempoError
            ) {
                HStack {
                    Text("Mid Tempo")
                    TextField("", text: $vm.midTempoString)
                        .frame(maxWidth: 60)
                }
            }

            ErrorFieldContainer(
                hasError: vm.midTempoTimesToPlayError != nil,
                errorMessage: vm.midTempoTimesToPlayError
            ) {
                HStack {
                    Text("Mid Tempo Times To Play")
                    TextField("", text: $vm.midTempoTimesToPlayString)
                        .frame(maxWidth: 60)
                }
            }

            ErrorFieldContainer(
                hasError: vm.fastTempoError != nil,
                errorMessage: vm.fastTempoError
            ) {
                HStack {
                    Text("Fast Tempo")
                    TextField("", text: $vm.fastTempoString)
                        .frame(maxWidth: 60)
                }
            }

            ErrorFieldContainer(
                hasError: vm.fastTempoTimesToPlayError != nil,
                errorMessage: vm.fastTempoTimesToPlayError
            ) {
                HStack {
                    Text("Fast Tempo Times To Play")
                    TextField("", text: $vm.fastTempoTimesToPlayString)
                        .frame(maxWidth: 60)
                }
            }

            ErrorFieldContainer(
                hasError: vm.numberOfBouncesError != nil,
                errorMessage: vm.numberOfBouncesError
            ) {
                HStack {
                    Text("Number Of Bounces")
                    TextField("", text: $vm.numberOfBouncesString)
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
