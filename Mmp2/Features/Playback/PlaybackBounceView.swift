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
            Section("Slow Tempo") {
                ErrorFieldContainer(
                    hasError: vm.slowTempoError != nil,
                    errorMessage: vm.slowTempoError
                ) {
                    TextField("", text: $vm.slowTempoString)
                        .frame(maxWidth: 60)
                }
            }
            
            Section("Slow Tempo Times To Play") {
                ErrorFieldContainer(
                    hasError: vm.slowTempoTimesToPlayError != nil,
                    errorMessage: vm.slowTempoTimesToPlayError
                ) {
                    TextField("", text: $vm.slowTempoTimesToPlayString)
                        .frame(maxWidth: 60)
                }
            }
            
            Section("Mid Tempo") {
                ErrorFieldContainer(
                    hasError: vm.midTempoError != nil,
                    errorMessage: vm.midTempoError
                ) {
                    TextField("", text: $vm.midTempoString)
                        .frame(maxWidth: 60)
                }
            }
            
            Section("Mid Tempo Times To Play") {
                ErrorFieldContainer(
                    hasError: vm.midTempoTimesToPlayError != nil,
                    errorMessage: vm.midTempoTimesToPlayError
                ) {
                    TextField("", text: $vm.midTempoTimesToPlayString)
                        .frame(maxWidth: 60)
                }
            }
            
            Section("Fast Tempo") {
                ErrorFieldContainer(
                    hasError: vm.fastTempoError != nil,
                    errorMessage: vm.fastTempoError
                ) {
                    TextField("", text: $vm.fastTempoString)
                        .frame(maxWidth: 60)
                }
            }
            
            Section("Fast Tempo Times To Play") {
                ErrorFieldContainer(
                    hasError: vm.fastTempoTimesToPlayError != nil,
                    errorMessage: vm.fastTempoTimesToPlayError
                ) {
                    TextField("", text: $vm.fastTempoTimesToPlayString)
                        .frame(maxWidth: 60)
                }
            }
            
            Section("Number Of Bounces") {
                ErrorFieldContainer(
                    hasError: vm.numberOfBouncesError != nil,
                    errorMessage: vm.numberOfBouncesError
                ) {
                    TextField("", text: $vm.numberOfBouncesString)
                        .frame(maxWidth: 60)
                }
            }
            
            Section("Play Order") {
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

//#Preview {
//    PlaybackBounceView()
//}
