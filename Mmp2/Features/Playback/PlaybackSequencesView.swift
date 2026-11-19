//
//  PlaybackSequenceView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/12/26.
//

import SwiftUI

struct PlaybackSequencesView: View {
    @Bindable var vm: PlaybackSequencesViewModel
    @State private var selectedRow: Int?
    var isBPM: Bool
    
    var body: some View {
        let _ = print("PlaybackSequencesView body")
        GroupBox("Sequence")
        {
            HStack(spacing: 0) {
                PlaybackSequenceTableView(
                    vm: vm,
                    selectedRow: $selectedRow,
                    tableRevision: vm.tableRevision
                )
                Divider()
                toolbar
                    .frame(maxWidth: 30)
            }
            .frame(minHeight: 300)
        }
    }
}

private extension PlaybackSequencesView {

    var toolbar: some View {

        VStack(spacing: 8) {

            Button {
                selectedRow = vm.addSequence()
            } label: {
                Label("Add", systemImage: "plus")
            }

            Button {
                guard let row = selectedRow else {
                    return
                }

                selectedRow = vm.delete(at: row)

            } label: {
                Label("Delete", systemImage: "trash")
            }
            .disabled(selectedRow == nil)

            Divider()

            Button {
                guard let row = selectedRow else {
                    return
                }

                selectedRow = vm.moveUp(row: row)

            } label: {
                Image(systemName: "arrow.up")
            }
            .disabled(
                selectedRow == nil ||
                selectedRow == 0
            )

            Button {
                guard let row = selectedRow else {
                    return
                }

                selectedRow = vm.moveDown(row: row)

            } label: {
                Image(systemName: "arrow.down")
            }
            .disabled(
                selectedRow == nil ||
                selectedRow == vm.sequenceVMs.count - 1
            )

            Spacer()
        }
        .padding()
    }
}
//#Preview {
//    PlaybackSequenceView()
//}
