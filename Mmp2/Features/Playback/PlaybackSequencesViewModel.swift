//
//  PlaybackSequenceViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/12/26.
//

import AppKit
import Foundation
import SwiftData

@Observable
final class PlaybackSequencesViewModel {
    var sequenceVMs: [PlaybackSequenceViewModel]
    var tableRevision = 0
    
    init(sequences: [PlaybackSequence]) {
        self.sequenceVMs = sequences
            .sorted { $0.playOrder < $1.playOrder }
            .map { PlaybackSequenceViewModel(sequence: $0) }
    }
    
    static func draft() -> PlaybackSequencesViewModel {
        PlaybackSequencesViewModel(sequences: [])
    }

    func scaleRates(by factor: Double) {
        sequenceVMs.forEach { $0.scaleRate(by: factor) }
        tableRevision += 1
    }
    
    func addSequence() -> Int {
        sequenceVMs.append(
            PlaybackSequenceViewModel(
                sequence: PlaybackSequence(
                    playOrder: sequenceVMs.count + 1,
                    value: 120,
                    timesToPlay: nil
                )
            )
        )
        
        return sequenceVMs.count - 1
    }

    @discardableResult
    func delete(at row: Int) -> Int? {

        guard sequenceVMs.indices.contains(row) else {
            return nil
        }

        sequenceVMs.remove(at: row)

        if sequenceVMs.isEmpty {
            return nil
        }

        return min(row, sequenceVMs.count - 1)
    }
    
    @discardableResult
    func moveUp(row: Int) -> Int? {
        guard row > 0 else {
            return nil
        }

        move(from: row, to: row - 1)

        return row - 1
    }
    
    @discardableResult
    func moveDown(row: Int) -> Int? {
        guard row < sequenceVMs.count - 1 else {
            return nil
        }

        move(from: row, to: row + 1)

        return row + 1
    }
    
    func move(
        from sourceIndex: Int,
        to destinationIndex: Int
    ) {
        let item = sequenceVMs.remove(at: sourceIndex)
        sequenceVMs.insert(item, at: destinationIndex)
    }

    var isValid: Bool {
        sequenceVMs.reduce(true) {
            $0 && $1.isValid
        }
    }

    func validate() {
        sequenceVMs.forEach { $0.validate() }
    }
    
    func apply(to sequences: [PlaybackSequence], context: ModelContext) throws -> (sequencesToAdd: [PlaybackSequence], sequencesToDelete: [PlaybackSequence]) {
        validate()
        
        guard isValid else {
            throw AppError.attemptToSaveInvalidState("PlaybackConstant")
        }
        
        normalizePlayOrders(self.sequenceVMs)
        let setDiffs = loadSequenceSetDiffs(sequences: sequences, viewModels: self.sequenceVMs)
        setDiffs.sequencesToDelete.forEach { context.delete($0) }
        for viewModel in setDiffs.sequencesToAdd {
            try viewModel.apply(to: viewModel.sequence)
        }
        for (sequence, viewModel) in setDiffs.sequencesToUpdate {
            try viewModel.apply(to: sequence)
        }
        
        let sequencesToAdd = setDiffs.sequencesToAdd.map { $0.sequence }
        return (sequencesToAdd, setDiffs.sequencesToDelete)
    }
    
    private func normalizePlayOrders(_ sequenceVMs: [PlaybackSequenceViewModel]) {
        var playOrder = 1;
        for vm in sequenceVMs {
            vm.sequence.playOrder = playOrder
            playOrder = playOrder + 1
        }
    }
    
    private func loadSequenceSetDiffs(sequences: [PlaybackSequence], viewModels: [PlaybackSequenceViewModel]) -> PlaybackSequenceSetDiffs {
        let sequencesById = Dictionary(
            uniqueKeysWithValues:
                sequences.map { ($0.persistentModelID, $0) }
        )

        let viewModelsById = Dictionary(
            uniqueKeysWithValues:
                viewModels.map { ($0.sequence.persistentModelID, $0) }
        )

        let sequenceIds = Set(sequencesById.keys)
        let viewModelIds = Set(viewModelsById.keys)
        
        let sequencesToDelete = sequenceIds
            .subtracting(viewModelIds)
            .compactMap { sequencesById[$0] }
        
        let sequencesToAdd = viewModelIds
            .subtracting(sequenceIds)
            .compactMap { viewModelsById[$0] }
        
        let sequencesToUpdate: [(existing: PlaybackSequence, working: PlaybackSequenceViewModel)] =
            sequenceIds.intersection(viewModelIds).compactMap { id in
                guard let sequence = sequencesById[id],
                      let vm = viewModelsById[id]
                else {
                    return nil
                }

                return (sequence, vm)
            }
        
        return PlaybackSequenceSetDiffs(sequencesToDelete: sequencesToDelete, sequencesToAdd: sequencesToAdd, sequencesToUpdate: sequencesToUpdate)
    }
    
    private struct PlaybackSequenceSetDiffs {
        let sequencesToDelete: [PlaybackSequence]
        let sequencesToAdd: [PlaybackSequenceViewModel]
        let sequencesToUpdate: [(existing: PlaybackSequence, working: PlaybackSequenceViewModel)]
    }
}
