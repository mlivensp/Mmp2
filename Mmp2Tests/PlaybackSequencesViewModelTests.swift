//
//  PlaybackSequencesViewModelTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 11/13/26.
//

import Testing
@testable import Mmp2

@Suite
struct PlaybackSequencesViewModelTests {

    private func makeSequence(
        playOrder: Int,
        value: Int
    ) -> PlaybackSequence {
        PlaybackSequence(
            playOrder: playOrder,
            value: value,
            timesToPlay: nil
        )
    }

    @Test
    func addSequence_appendsDefaultSequence() {
        let vm = PlaybackSequencesViewModel(
            sequences: []
        )

        let row = vm.addSequence()

        #expect(row == 0)
        #expect(vm.sequenceVMs.count == 1)
        #expect(vm.sequenceVMs[0].value == 120)
    }

    @Test
    func delete_invalidRowReturnsNil() {
        let vm = PlaybackSequencesViewModel(
            sequences: []
        )

        #expect(vm.delete(at: 0) == nil)
    }

    @Test
    func delete_onlyRowReturnsNilSelection() {
        let vm = PlaybackSequencesViewModel(
            sequences: [
                makeSequence(playOrder: 1, value: 100)
            ]
        )

        let selectedRow = vm.delete(at: 0)

        #expect(selectedRow == nil)
        #expect(vm.sequenceVMs.isEmpty)
    }

    @Test
    func delete_middleRowReturnsSameIndex() {
        let vm = PlaybackSequencesViewModel(
            sequences: [
                makeSequence(playOrder: 1, value: 100),
                makeSequence(playOrder: 2, value: 200),
                makeSequence(playOrder: 3, value: 300)
            ]
        )

        let selectedRow = vm.delete(at: 1)

        #expect(selectedRow == 1)
        #expect(vm.sequenceVMs.count == 2)
    }

    @Test
    func delete_lastRowReturnsPreviousRow() {
        let vm = PlaybackSequencesViewModel(
            sequences: [
                makeSequence(playOrder: 1, value: 100),
                makeSequence(playOrder: 2, value: 200)
            ]
        )

        let selectedRow = vm.delete(at: 1)

        #expect(selectedRow == 0)
    }

    @Test
    func moveUp_movesItem() {
        let vm = PlaybackSequencesViewModel(
            sequences: [
                makeSequence(playOrder: 1, value: 100),
                makeSequence(playOrder: 2, value: 200),
                makeSequence(playOrder: 3, value: 300)
            ]
        )

        let result = vm.moveUp(row: 1)

        #expect(result == 0)

        #expect(vm.sequenceVMs[0].value == 200)
        #expect(vm.sequenceVMs[1].value == 100)
    }

    @Test
    func moveUp_firstRowReturnsNil() {
        let vm = PlaybackSequencesViewModel(
            sequences: [
                makeSequence(playOrder: 1, value: 100)
            ]
        )

        #expect(vm.moveUp(row: 0) == nil)
    }

    @Test
    func moveDown_movesItem() {
        let vm = PlaybackSequencesViewModel(
            sequences: [
                makeSequence(playOrder: 1, value: 100),
                makeSequence(playOrder: 2, value: 200),
                makeSequence(playOrder: 3, value: 300)
            ]
        )

        let result = vm.moveDown(row: 1)

        #expect(result == 2)

        #expect(vm.sequenceVMs[1].value == 300)
        #expect(vm.sequenceVMs[2].value == 200)
    }

    @Test
    func moveDown_lastRowReturnsNil() {
        let vm = PlaybackSequencesViewModel(
            sequences: [
                makeSequence(playOrder: 1, value: 100)
            ]
        )

        #expect(vm.moveDown(row: 0) == nil)
    }

    @Test
    func scaleRates_scalesAllSequences() {
        let vm = PlaybackSequencesViewModel(
            sequences: [
                makeSequence(playOrder: 1, value: 100),
                makeSequence(playOrder: 2, value: 200)
            ]
        )

        vm.scaleRates(by: 2)

        #expect(vm.sequenceVMs[0].value == 200)
        #expect(vm.sequenceVMs[1].value == 400)
    }

    @Test
    func isValid_falseWhenChildInvalid() {
        let vm = PlaybackSequencesViewModel(
            sequences: [
                makeSequence(playOrder: 1, value: 100),
                makeSequence(playOrder: 2, value: 200)
            ]
        )

        vm.sequenceVMs[1].valueString = "abc"

        #expect(vm.isValid == false)
    }

    @Test
    func validate_marksCollectionValid() {
        let vm = PlaybackSequencesViewModel(
            sequences: [
                makeSequence(playOrder: 1, value: 100)
            ]
        )

        vm.validate()

        #expect(vm.isValid)
    }
}
