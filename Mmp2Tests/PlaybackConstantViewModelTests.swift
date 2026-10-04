//
//  PlaybackConstantViewModelTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Testing
@testable import Mmp2

@MainActor
struct PlaybackConstantViewModelTests {

    @Test func validRate() async throws {
        let vm = PlaybackConstantViewModel(rate: 0, timesToPlay: nil)
        vm.rateString = "42"
        #expect(vm.rateError == nil)
    }

    @Test func invalidRateFormat() async throws {
        let vm = PlaybackConstantViewModel(rate: 0, timesToPlay: nil)
        vm.rateString = "42b"
        #expect(vm.rateError != nil)
    }

    @Test func validTimesToPlay() async throws {
        let vm = PlaybackConstantViewModel(rate: 0, timesToPlay: nil)
        vm.timesToPlayString = "6"
        #expect(vm.timesToPlayError == nil)
    }

    @Test func invalidTimesToPlayFormat() async throws {
        let vm = PlaybackConstantViewModel(rate: 0, timesToPlay: nil)
        vm.timesToPlayString = "6-5"
        #expect(vm.timesToPlayError != nil)
    }
}
