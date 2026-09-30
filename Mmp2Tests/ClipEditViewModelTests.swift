//
//  ClipEditViewModelTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 9/29/26.
//

import Testing
@testable import Mmp2

@MainActor
struct ClipEditViewModelTests {
    @Test func testSecondsValidation() async throws {
        let vm = createVm();
        vm.startTimeString = "00:01:12.25"
        vm.endTimeString = "00:02:12.25"
        #expect(vm.startSecondsError == nil)
        #expect(vm.startSeconds == 72.25)
        #expect(vm.endSecondsError == nil)
        #expect(vm.endSeconds == 132.25)
    }
    
    @Test func testEndSecondsFormatBad() async throws {
        let vm = createVm()
        vm.startTimeString = "ab:cd"
        vm.endTimeString = "4:5:6:7:8"
        #expect(vm.startSecondsError != nil)
        #expect(vm.endSecondsError != nil)
    }
    
    @Test func testSecondsRangeError() async throws {
        let vm = createVm()
        vm.startTimeString = "00:02:05.72"
        vm.endTimeString = "00:01:45.13"
        #expect(vm.startSecondsError != nil)
        #expect(vm.endSecondsError != nil)
    }
    
    @Test func testMeasureValidation() async throws {
        let clip = createClip();
        let source = createSource();
        source.measure1Start = 32.6
        let vm = ClipEditView.ViewModel(clip: clip, source: source)
        vm.startMeasureString = "3"
        vm.endMeasureString = "5"
        #expect(vm.startMeasureError == nil)
        #expect(Int(vm.startMeasureString) == 3)
        #expect(vm.endMeasureError == nil)
        #expect(Int(vm.endMeasureString) == 5)
    }
    
    @Test func testStartMeasureFormatBad() async throws {
        let clip = createClip();
        let source = createSource();
        source.measure1Start = 32.6
        let vm = ClipEditView.ViewModel(clip: clip, source: source)
        vm.startMeasureString = "d"
        vm.endMeasureString = "5"
        #expect(vm.startMeasureError != nil)
        #expect(vm.endMeasureError == nil)
    }
    
    @Test func testEndMeasureFormatBad() async throws {
        let clip = createClip();
        let source = createSource();
        source.measure1Start = 32.6
        let vm = ClipEditView.ViewModel(clip: clip, source: source)
        vm.startMeasureString = "3"
        vm.endMeasureString = "5.625"
        #expect(vm.startMeasureError == nil)
        #expect(vm.endMeasureError != nil)
    }

    @Test func testMeasureRangeError() async throws {
        let clip = createClip();
        let source = createSource();
        source.measure1Start = 32.6
        let vm = ClipEditView.ViewModel(clip: clip, source: source)
        vm.startMeasureString = "3"
        vm.endMeasureString = "2"
        #expect(vm.startMeasureError != nil)
        #expect(vm.endMeasureError != nil)
    }

    fileprivate func createVm() -> ClipEditView.ViewModel {
        let clip = createClip()
        let source = createSource()
        return ClipEditView.ViewModel(clip: clip, source: source)
    }

    fileprivate func createClip() -> Mmp2.Clip {
        let dummyMedia = Mmp2.Media(bpm: 120, path: "", duration: 60)
        let dummyPlayback = Mmp2.Playback()
        return Mmp2.Clip(source: nil, name: "Sample Clip", startSeconds: 10, endSeconds: 20, startMeasure: 1, endMeasure: 4, isFavorite: false, notes: "Sample", media: dummyMedia, playback: dummyPlayback)
    }
    
    fileprivate func createSource() -> Mmp2.Source {
        let dummySourceMedia = Mmp2.Media(bpm: 90, path: "", duration: 62)
        let dummySourcePlayback = Mmp2.Playback()
        return Mmp2.Source(name: "Sample Source", sortOrder: 0, measure1Start: nil, isFavorite: false, notes: nil, media: dummySourceMedia, playback: dummySourcePlayback, sourceGroup: nil)

    }
}
