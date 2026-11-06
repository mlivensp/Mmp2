//
//  BounceSequenceGenerator.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/5/26.
//

import Foundation

struct BounceSequenceGenerator: SequenceGenerator {
    let bounce: PlaybackBounce
    
    func generateSequence() -> [TempoStep] {
        var sortableList: [(sortOrder: Int, tempoStep: TempoStep)] = []
        sortableList.append(
            contentsOf: buildSortableTempoSteps(
                tempo: bounce.slow,
                timesToPlay: bounce.timesToPlaySlow,
                sortOrder: bounce.playOrder?.slowOrder ?? 1
            ))
        sortableList.append(
            contentsOf: buildSortableTempoSteps(
                tempo: bounce.mid,
                timesToPlay: bounce.timesToPlayMid,
                sortOrder: bounce.playOrder?.midOrder ?? 2
            ))
        sortableList.append(
            contentsOf: buildSortableTempoSteps(
                tempo: bounce.fast,
                timesToPlay: bounce.timesToPlayFast,
                sortOrder: bounce.playOrder?.fastOrder ?? 3
            ))
        return sortableList
            .sorted(by: { $0.sortOrder < $1.sortOrder} )
            .map { $0.tempoStep }
   }
    
    private func buildSortableTempoSteps(tempo: Int, timesToPlay: Int, sortOrder: Int) -> [(sortOrder: Int, tempoStep: TempoStep)] {
        var steps: [(sortOrder: Int, tempoStep: TempoStep)] = []
        for i in 0..<timesToPlay {
            steps.append((sortOrder, TempoStep(
                tempo: Float(tempo),
                tempoIndex: i + 1,
                tempoCount: timesToPlay,
                sequenceIndex: 1,
                sequenceOccurrence: 1)))
        }
        
        return steps
    }
}
