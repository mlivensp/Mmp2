//
//  PlaybackSequenceViewModelTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 11/13/26.
//

import Testing
@testable import Mmp2

@Suite
struct PlaybackSequenceViewModelTests {

    // MARK: - Helpers

    private func makeSequence(
        playOrder: Int = 1,
        value: Int = 120,
        timesToPlay: Int? = nil
    ) -> PlaybackSequence {
        PlaybackSequence(
            playOrder: playOrder,
            value: value,
            timesToPlay: timesToPlay
        )
    }

    // MARK: - Initialization

    @Test
    func init_loadsValuesFromModel() {
        let sequence = makeSequence(
            playOrder: 3,
            value: 140,
            timesToPlay: 5
        )

        let vm = PlaybackSequenceViewModel(sequence: sequence)

        #expect(vm.value == 140)
        #expect(vm.timesToPlay == 5)
        #expect(vm.valueString == "140")
        #expect(vm.timesToPlayString == "5")
    }

    @Test
    func init_nilTimesToPlayProducesEmptyString() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence(timesToPlay: nil)
        )

        #expect(vm.timesToPlay == nil)
        #expect(vm.timesToPlayString.isEmpty)
    }

    // MARK: - Value Validation

    @Test
    func validateValue_acceptsPositiveInteger() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence()
        )

        let result = vm.validateValue("150")

        switch result {
        case .success(let value):
            #expect(value == 150)

        case .failure:
            Issue.record("Expected success")
        }
    }

    @Test
    func validateValue_rejectsEmpty() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence()
        )

        let result = vm.validateValue("")

        switch result {
        case .failure(let message):
            #expect(message == "Value is required.")

        default:
            Issue.record("Expected failure")
        }
    }

    @Test
    func validateValue_rejectsZero() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence()
        )

        let result = vm.validateValue("0")

        switch result {
        case .failure:
            #expect(true)

        default:
            Issue.record("Expected failure")
        }
    }

    @Test
    func validateValue_rejectsNegativeNumber() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence()
        )

        let result = vm.validateValue("-5")

        switch result {
        case .failure:
            #expect(true)

        default:
            Issue.record("Expected failure")
        }
    }

    @Test
    func validateValue_rejectsNonNumeric() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence()
        )

        let result = vm.validateValue("abc")

        switch result {
        case .failure:
            #expect(true)

        default:
            Issue.record("Expected failure")
        }
    }

    // MARK: - TimesToPlay Validation

    @Test
    func validateTimesToPlay_acceptsEmpty() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence()
        )

        let result = vm.validateTimesToPlay("")

        switch result {
        case .success(let value):
            #expect(value == nil)

        default:
            Issue.record("Expected success")
        }
    }

    @Test
    func validateTimesToPlay_acceptsPositiveInteger() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence()
        )

        let result = vm.validateTimesToPlay("3")

        switch result {
        case .success(let value):
            #expect(value == 3)

        default:
            Issue.record("Expected success")
        }
    }

    @Test
    func validateTimesToPlay_rejectsZero() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence()
        )

        let result = vm.validateTimesToPlay("0")

        switch result {
        case .failure:
            #expect(true)

        default:
            Issue.record("Expected failure")
        }
    }

    // MARK: - Property Setters

    @Test
    func valueString_updatesValueWhenValid() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence()
        )

        vm.valueString = "180"

        #expect(vm.value == 180)
        #expect(vm.valueError == nil)
    }

    @Test
    func valueString_setsErrorWhenInvalid() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence()
        )

        vm.valueString = "-1"

        #expect(vm.valueError != nil)
    }

    @Test
    func timesToPlayString_updatesTimesToPlayWhenValid() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence()
        )

        vm.timesToPlayString = "4"

        #expect(vm.timesToPlay == 4)
        #expect(vm.timesToPlayError == nil)
    }

    @Test
    func timesToPlayString_acceptsEmptyString() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence(timesToPlay: 7)
        )

        vm.timesToPlayString = ""

        #expect(vm.timesToPlay == nil)
        #expect(vm.timesToPlayError == nil)
    }

    // MARK: - Scaling

    @Test
    func scaleRate_multipliesValue() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence(value: 120)
        )

        vm.scaleRate(by: 2.0)

        #expect(vm.value == 240)
        #expect(vm.valueString == "240")
    }

    @Test
    func scaleRate_doesNothingWhenCurrentValueInvalid() {
        let vm = PlaybackSequenceViewModel(
            sequence: makeSequence(value: 120)
        )

        vm.valueString = "abc"

        vm.scaleRate(by: 2)

        #expect(vm.value == 120)
    }

    // MARK: - Apply

    @Test
    func apply_copiesValuesToTargetModel() throws {
        let source = makeSequence(
            playOrder: 5,
            value: 120,
            timesToPlay: nil
        )

        let target = makeSequence(
            playOrder: 1,
            value: 90,
            timesToPlay: 2
        )

        let vm = PlaybackSequenceViewModel(sequence: source)

        vm.valueString = "200"
        vm.timesToPlayString = "6"

        try vm.apply(to: target)

        #expect(target.playOrder == 5)
        #expect(target.value == 200)
        #expect(target.timesToPlay == 6)
    }

    @Test
    func apply_throwsWhenInvalid() {
        let source = makeSequence()
        let target = makeSequence()

        let vm = PlaybackSequenceViewModel(sequence: source)

        vm.valueString = "abc"

        #expect(throws: AppError.self) {
            try vm.apply(to: target)
        }
    }
}
