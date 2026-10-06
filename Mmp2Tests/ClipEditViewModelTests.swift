//
//  ClipEditViewModelTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 9/29/26.
//

import Testing
import Foundation
import SwiftData
@testable import Mmp2

@MainActor
@Suite("ClipEditViewContent.ViewModel", .serialized)
struct ClipEditViewModelTests {

    // MARK: - Init

    @Test("init maps clip values to view model state")
    func initMapsValues() throws {
        let f = try Fixture(name: "Intro", startSeconds: 10, endSeconds: 20, bpm: 120)

        #expect(f.vm.name == "Intro")
        #expect(f.vm.bpmString == "120")
        #expect(f.vm.startSeconds == 10)
        #expect(f.vm.endSeconds == 20)
        #expect(f.vm.startTimeString == TimeFormatter.shared.string(from: 10))
        #expect(f.vm.endTimeString == TimeFormatter.shared.string(from: 20))
        #expect(f.vm.startMeasureString == "")
        #expect(f.vm.endMeasureString == "")
    }

    @Test("init with nil bpm uses empty bpm string")
    func initNilBpm() throws {
        let f = try Fixture(bpm: nil)
        #expect(f.vm.bpmString == "")
    }

    // MARK: - Name

    @Test("name rejects blank input", arguments: ["", "   "])
    func nameRejectsBlank(input: String) throws {
        let f = try Fixture()
        f.vm.name = input

        #expect(f.vm.nameError == "Name is required.")
        #expect(!f.vm.isValid)
    }

    @Test("name accepts a unique value and clears the error")
    func nameAcceptsUnique() throws {
        let f = try Fixture()
        f.vm.name = ""
        #expect(f.vm.nameError != nil)

        f.vm.name = "Unique Name"

        #expect(f.vm.nameError == nil)
    }

    // Fails until validateNameUniqueness compares against nameValue
    // instead of clip.primitiveName.
    @Test("name rejects a duplicate of another clip in the source")
    func nameRejectsDuplicate() throws {
        let f = try Fixture(name: "Mine", otherClipNames: ["Taken"])

        f.vm.name = "Taken"

        #expect(f.vm.nameError == "A clip with this name already exists.")
    }

    @Test("name allows keeping the clip's own name")
    func nameAllowsOwnName() throws {
        let f = try Fixture(name: "Mine", otherClipNames: ["Other"])

        f.vm.name = "Mine"

        #expect(f.vm.nameError == nil)
    }

    // MARK: - BPM

    @Test("bpm accepts a whole number and forwards it to playbackVM")
    func bpmAcceptsNumber() throws {
        let f = try Fixture()
        f.vm.bpmString = "90"

        #expect(f.vm.bpmError == nil)
        #expect(f.vm.bpm == 90)
        #expect(f.vm.playbackVM.bpm == 90)
    }

    @Test("bpm empty is valid and sets nil")
    func bpmEmptyIsNil() throws {
        let f = try Fixture(bpm: 100)
        f.vm.bpmString = ""

        #expect(f.vm.bpmError == nil)
        #expect(f.vm.bpm == nil)
        #expect(f.vm.playbackVM.bpm == nil)
    }

    @Test("bpm rejects non-integer input", arguments: ["abc", "1.5", "12x"])
    func bpmRejectsInvalid(input: String) throws {
        let f = try Fixture(bpm: 100)
        f.vm.bpmString = input

        #expect(f.vm.bpmError == "BPM must be a valid whole number.")
        #expect(!f.vm.isValid)
    }

    @Test("bpm error clears after valid input")
    func bpmErrorClears() throws {
        let f = try Fixture()
        f.vm.bpmString = "x"
        #expect(f.vm.bpmError != nil)

        f.vm.bpmString = "100"

        #expect(f.vm.bpmError == nil)
    }

    // MARK: - Start / end time

    @Test("valid start and end times update seconds")
    func validTimes() throws {
        let f = try Fixture(startSeconds: 10, endSeconds: 20)
        f.vm.startTimeString = TimeFormatter.shared.string(from: 5)
        f.vm.endTimeString = TimeFormatter.shared.string(from: 12)

        #expect(f.vm.startSecondsError == nil)
        #expect(f.vm.endSecondsError == nil)
        #expect(f.vm.startSeconds == 5)
        #expect(f.vm.endSeconds == 12)
    }

    @Test("invalid start time sets only the start error")
    func invalidStartTime() throws {
        let f = try Fixture()
        f.vm.startTimeString = "bad"

        #expect(f.vm.startSecondsError == "Start Time must be a valid time string.")
        #expect(f.vm.endSecondsError == nil)
        #expect(!f.vm.isValid)
    }

    @Test("invalid end time sets only the end error")
    func invalidEndTime() throws {
        let f = try Fixture()
        f.vm.endTimeString = "bad"

        #expect(f.vm.endSecondsError == "End time must be a valid time string.")
        #expect(f.vm.startSecondsError == nil)
    }

    @Test("end before start sets range errors on both fields")
    func endBeforeStart() throws {
        let f = try Fixture(startSeconds: 10, endSeconds: 20)
        f.vm.endTimeString = TimeFormatter.shared.string(from: 5)

        #expect(f.vm.startSecondsError == "Start time must be before end time.")
        #expect(f.vm.endSecondsError == "End time must be after start time.")
        #expect(!f.vm.isValid)
    }

    @Test("end equal to start is rejected")
    func endEqualsStart() throws {
        let f = try Fixture(startSeconds: 10, endSeconds: 20)
        f.vm.endTimeString = TimeFormatter.shared.string(from: 10)

        #expect(f.vm.endSecondsError != nil)
    }

    // MARK: - Measures

    @Test("valid measures produce no errors")
    func validMeasures() throws {
        let f = try Fixture()
        f.vm.startMeasureString = "1"
        f.vm.endMeasureString = "5"

        #expect(f.vm.firstMeasureError == nil)
        #expect(f.vm.lastMeasureError == nil)
        #expect(f.vm.firstMeasure == 1)
        #expect(f.vm.lastMeasure == 5)
    }

    @Test("empty measure is required")
    func emptyMeasureRequired() throws {
        let f = try Fixture()
        f.vm.startMeasureString = ""
        #expect(f.vm.firstMeasureError == "Start measure is required.")

        f.vm.endMeasureString = ""
        #expect(f.vm.lastMeasureError == "End measure is required.")
    }

    @Test("non-numeric measure is rejected")
    func nonNumericMeasure() throws {
        let f = try Fixture()
        f.vm.startMeasureString = "a"
        f.vm.endMeasureString = "b"

        #expect(f.vm.firstMeasureError == "Start measure must be a whole number.")
        #expect(f.vm.lastMeasureError == "End measure must be a whole number.")
    }

    @Test("last measure not after first sets range errors")
    func measureRange() throws {
        let f = try Fixture()
        f.vm.startMeasureString = "4"
        f.vm.endMeasureString = "4"

        #expect(f.vm.firstMeasureError == "Start measure must be before end measure.")
        #expect(f.vm.lastMeasureError == "End measure must be after start measure.")
        #expect(!f.vm.isValid)
    }

    // MARK: - validate()

    @Test("validate in time mode clears measure errors")
    func validateTimeModeClearsMeasureErrors() throws {
        let f = try Fixture()
        f.vm.startMeasureString = ""
        #expect(f.vm.firstMeasureError != nil)

        f.vm.measureMode = false
        let result = f.vm.validate()

        #expect(f.vm.firstMeasureError == nil)
        #expect(f.vm.lastMeasureError == nil)
        #expect(result)
    }

    @Test("validate in measure mode clears time errors")
    func validateMeasureModeClearsTimeErrors() throws {
        let f = try Fixture()
        f.vm.startTimeString = "bad"
        #expect(f.vm.startSecondsError != nil)

        f.vm.measureMode = true
        f.vm.startMeasureString = "1"
        f.vm.endMeasureString = "2"
        let result = f.vm.validate()

        #expect(f.vm.startSecondsError == nil)
        #expect(f.vm.endSecondsError == nil)
        #expect(result)
    }

    @Test("validate in measure mode fails when measures are empty")
    func validateMeasureModeEmpty() throws {
        let f = try Fixture()
        f.vm.measureMode = true
        f.vm.startMeasureString = ""
        f.vm.endMeasureString = ""

        #expect(!f.vm.validate())
    }

    // MARK: - save()

    @Test("save returns false and leaves the clip unchanged when invalid")
    func saveInvalid() throws {
        let f = try Fixture(name: "Original")
        f.vm.name = ""

        let saved = try f.vm.save()

        #expect(!saved)
        #expect(f.clip.primitiveName == "Original")
    }

    @Test("save writes fields to the clip in time mode and clears measures")
    func saveTimeMode() throws {
        let f = try Fixture(name: "Original", startSeconds: 10, endSeconds: 20)
        f.vm.measureMode = false
        f.vm.name = "Updated"
        f.vm.startTimeString = TimeFormatter.shared.string(from: 3)
        f.vm.endTimeString = TimeFormatter.shared.string(from: 9)
        f.vm.isFavorite = true
        f.vm.notes = ""

        let saved = try f.vm.save()

        #expect(saved)
        #expect(f.clip.primitiveName == "Updated")
        #expect(f.clip.startSeconds == 3)
        #expect(f.clip.endSeconds == 9)
        #expect(f.clip.isFavorite)
        #expect(f.clip.notes == nil)
        #expect(f.clip.firstMeasure == nil)
        #expect(f.clip.lastMeasure == nil)
    }

    @Test("save stores non-empty notes")
    func saveNotes() throws {
        let f = try Fixture()
        f.vm.notes = "hello"

        _ = try f.vm.save()

        #expect(f.clip.notes == "hello")
    }

    @Test("save writes measures in measure mode")
    func saveMeasureMode() throws {
        let f = try Fixture()
        f.vm.measureMode = true
        f.vm.startMeasureString = "2"
        f.vm.endMeasureString = "6"

        let saved = try f.vm.save()

        #expect(saved)
        #expect(f.clip.firstMeasure == 2)
        #expect(f.clip.lastMeasure == 6)
    }
}

// MARK: - Fixture

@MainActor
private final class Fixture {
    let container: ModelContainer
    let context: ModelContext
    let source: Source
    let clip: Clip
    let vm: ClipEditView.ViewModel

    init(
        name: String = "Clip",
        startSeconds: Double = 10,
        endSeconds: Double = 20,
        bpm: Int? = 100,
        otherClipNames: [String] = []
    ) throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: SchemaV1.schema,          // the static let you already defined
            configurations: config
        )
        context = ModelContext(container)
        let sourcePlayback = Playback()
        let sourceMedia = Media(bpm: nil, path: "source.mp3", duration: 60)
        context.insert(sourcePlayback)
        context.insert(sourceMedia)

        source = Source(
            name: "Source",
            sortOrder: 1,
            measure1Start: 0,
            isFavorite: false,
            notes: nil,
            media: sourceMedia,
            playback: sourcePlayback,
            sourceGroup: nil
        )
        context.insert(source)

        clip = Fixture.makeClip(
            name: name,
            start: startSeconds,
            end: endSeconds,
            bpm: bpm,
            source: source,
            context: context
        )
        source.clips.append(clip)

        for other in otherClipNames {
            let otherClip = Fixture.makeClip(
                name: other,
                start: 0,
                end: 1,
                bpm: nil,
                source: source,
                context: context
            )
            source.clips.append(otherClip)
        }
        
        try! context.save()

        vm = ClipEditView.ViewModel(clip: clip, source: source, context: context)
    }

    private static func makeClip(
        name: String,
        start: Double,
        end: Double,
        bpm: Int?,
        source: Source,
        context: ModelContext
    ) -> Clip {
        let clipPlayback = Playback()
        let clipMedia = Media(bpm: bpm, path: "clip.mp3", duration: end - start)
        context.insert(clipPlayback)
        context.insert(clipMedia)

        let clip = Clip(
            source: source,
            name: name,
            startSeconds: start,
            endSeconds: end,
            startMeasure: nil,
            endMeasure: nil,
            isFavorite: false,
            notes: nil,
            media: clipMedia,
            playback: clipPlayback
        )
        context.insert(clip)
        return clip
    }
}
