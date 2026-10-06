//
//  SourceEditViewModelTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 10/6/26.
//

import Testing
import SwiftData
@testable import Mmp2

@Suite("SourceEditView.ViewModel")
struct SourceEditViewModelTests {

    // MARK: - Fixtures

    private func makeModelContext() throws -> ModelContext {
        let schema = Schema([
            MediaCollection.self,
            Source.self,
            SourceGroup.self,
            Media.self,
            Playback.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    private func makeFixture(
        name: String = "Source A",
        sortOrder: Int = 1,
        measure1Start: Double? = nil,
        bpm: Int? = 120,
        isFavorite: Bool = false,
        notes: String? = nil,
        sourceGroupName: String? = nil,
        existingNames: [String] = []
    ) throws -> (context: ModelContext, collection: MediaCollection, source: Source, sourceGroup: SourceGroup?) {
        let context = try makeModelContext()

        let collection = MediaCollection(name: "Collection A")
        context.insert(collection)

        var sourceGroup: SourceGroup?
        if let sourceGroupName {
            sourceGroup = SourceGroup(name: sourceGroupName, sortOrder: 1, mediaCollection: collection)
            context.insert(sourceGroup!)
            collection.sourceGroups.append(sourceGroup!)
        }

        let media = Media(
            bpm: bpm,
            path: "/tmp/test.mp3",
            duration: 120.0,
            isArchived: false,
            pathIsValid: true,
            numberTimesPlayed: 0,
            lastPlayed: nil
        )
        context.insert(media)

        let playback = Playback()
        context.insert(playback)

        let source = Source(
            name: name,
            sortOrder: sortOrder,
            measure1Start: measure1Start,
            isFavorite: isFavorite,
            notes: notes,
            media: media,
            playback: playback,
            sourceGroup: sourceGroup
        )
        context.insert(source)

        source.mediaCollection = collection
        collection.sources.append(source)

        for existingName in existingNames {
            let existingMedia = Media(
                bpm: 100,
                path: "/tmp/\(existingName).mp3",
                duration: 60,
                isArchived: false,
                pathIsValid: true
            )
            let existingPlayback = Playback()
            context.insert(existingMedia)
            context.insert(existingPlayback)

            let existing = Source(
                name: existingName,
                sortOrder: 0,
                measure1Start: nil,
                isFavorite: false,
                notes: nil,
                media: existingMedia,
                playback: existingPlayback,
                sourceGroup: nil
            )
            context.insert(existing)
            existing.mediaCollection = collection
            collection.sources.append(existing)
        }

        return (context, collection, source, sourceGroup)
    }

    private func makeViewModel(
        name: String = "Source A",
        sortOrder: Int = 1,
        measure1Start: Double? = nil,
        bpm: Int? = 120,
        isFavorite: Bool = false,
        notes: String? = nil,
        sourceGroupName: String? = nil,
        existingNames: [String] = []
    ) throws -> SourceEditView.ViewModel {
        let fixture = try makeFixture(
            name: name,
            sortOrder: sortOrder,
            measure1Start: measure1Start,
            bpm: bpm,
            isFavorite: isFavorite,
            notes: notes,
            sourceGroupName: sourceGroupName,
            existingNames: existingNames
        )
        return SourceEditView.ViewModel(
            source: fixture.source,
            collection: fixture.collection,
            context: fixture.context
        )
    }

    // MARK: - Init

    @Test("init maps stored values to state and validates")
    func initMapsValues() throws {
        let vm = try makeViewModel(
            name: "Song 1",
            sortOrder: 7,
            measure1Start: 12.5,
            bpm: 128,
            isFavorite: true,
            notes: "favorite track"
        )

        #expect(vm.name == "Song 1")
        #expect(vm.sortOrderString == "7")
        #expect(vm.measure1StartString == TimeFormatter.shared.string(from: 12.5))
        #expect(vm.bpmString == "128")
        #expect(vm.isFavorite == true)
        #expect(vm.notes == "favorite track")
        #expect(vm.nameError == nil)
        #expect(vm.bpmError == nil)
        #expect(vm.sortOrderError == nil)
        #expect(vm.measure1StartError == nil)
        #expect(vm.isValid)
    }

    @Test("init with invalid name is marked invalid")
    func initWithInvalidName() throws {
        let vm = try makeViewModel(
            name: "   ",
            existingNames: ["Duplicate"]
        )

        #expect(vm.nameError == "Name is required.")
        #expect(!vm.isValid)
    }

    // MARK: - Name validation

    @Test("name accepts non-empty unique value")
    func nameAcceptsUniqueValue() throws {
        let vm = try makeViewModel(name: "Original", existingNames: ["Other"])
        vm.name = "New Name"

        #expect(vm.name == "New Name")
        #expect(vm.nameError == nil)
        #expect(vm.isValid)
    }

    @Test("name rejects empty string")
    func nameRejectsEmptyString() throws {
        let vm = try makeViewModel(name: "Original")
        vm.name = "   "

        #expect(vm.nameError == "Name is required.")
        #expect(!vm.isValid)
    }

    @Test("name rejects duplicate name in same collection")
    func nameRejectsDuplicateInCollection() throws {
        let vm = try makeViewModel(name: "Original", existingNames: ["Existing Name"])
        vm.name = "Existing Name"

        #expect(vm.nameError == "A source with this name already exists.")
        #expect(!vm.isValid)
    }

    // MARK: - BPM validation

    @Test("bpm accepts empty string as nil")
    func bpmAcceptsEmptyString() throws {
        let vm = try makeViewModel()
        vm.bpmString = ""

        #expect(vm.bpm == nil)
        #expect(vm.bpmError == nil)
        #expect(vm.playbackVM.bpm == nil)
    }

    @Test("bpm accepts valid integer")
    func bpmAcceptsValidInt() throws {
        let vm = try makeViewModel()
        vm.bpmString = "140"

        #expect(vm.bpm == 140)
        #expect(vm.bpmError == nil)
    }

    @Test("bpm rejects non-numeric string")
    func bpmRejectsInvalidString() throws {
        let vm = try makeViewModel()
        vm.bpmString = "abc"

        #expect(vm.bpmError == "BPM must be a valid whole number.")
        #expect(!vm.isValid)
    }

    // MARK: - Sort order validation

    @Test("sortOrder requires a value")
    func sortOrderRequiresValue() throws {
        let vm = try makeViewModel()
        vm.sortOrderString = ""

        #expect(vm.sortOrderError == "Sort Order is a required field.")
        #expect(!vm.isValid)
    }

    @Test("sortOrder accepts valid integer")
    func sortOrderAcceptsValidInt() throws {
        let vm = try makeViewModel()
        vm.sortOrderString = "9"

        #expect(vm.sortOrder == 9)
        #expect(vm.sortOrderError == nil)
    }

    @Test("sortOrder rejects non-numeric input")
    func sortOrderRejectsInvalidInput() throws {
        let vm = try makeViewModel()
        vm.sortOrderString = "three"

        #expect(vm.sortOrderError == "Sort Order must be a number >= 0.")
        #expect(!vm.isValid)
    }

    // MARK: - Measure 1 start validation

    @Test("measure1Start accepts empty string")
    func measure1StartAcceptsEmpty() throws {
        let vm = try makeViewModel()
        vm.measure1StartString = ""

        #expect(vm.measure1Start == nil)
        #expect(vm.measure1StartError == nil)
    }

    @Test("measure1Start accepts valid time string")
    func measure1StartAcceptsValidString() throws {
        let vm = try makeViewModel()
        vm.measure1StartString = "00:00:05"

        #expect(vm.measure1Start == 5.0)
        #expect(vm.measure1StartError == nil)
    }

    @Test("measure1Start rejects invalid format")
    func measure1StartRejectsInvalidFormat() throws {
        let vm = try makeViewModel()
        vm.measure1StartString = "bad"

        #expect(vm.measure1StartError == "Measure 1 Start must be empty or a valid time string.")
        #expect(!vm.isValid)
    }

    // MARK: - validate()

    @Test("validate clears all field errors when all inputs are valid")
    func validatePassesWhenAllFieldsValid() throws {
        let vm = try makeViewModel(
            name: "Valid Source",
            existingNames: ["Other"]
        )

        vm.name = "Valid Source"
        vm.bpmString = "110"
        vm.sortOrderString = "3"
        vm.measure1StartString = "00:00:08"

        #expect(vm.validate())
        #expect(vm.nameError == nil)
        #expect(vm.bpmError == nil)
        #expect(vm.sortOrderError == nil)
        #expect(vm.measure1StartError == nil)
        #expect(vm.isValid)
    }

    @Test("validate fails when any field is invalid")
    func validateFailsWhenAnyFieldInvalid() throws {
        let vm = try makeViewModel(name: "Unique Source")
        vm.name = ""
        vm.bpmString = "abc"
        vm.sortOrderString = ""
        vm.measure1StartString = "nope"

        let result = vm.validate()

        #expect(result == false)
        #expect(vm.nameError == "Name is required.")
        #expect(vm.bpmError == "BPM must be a valid whole number.")
        #expect(vm.sortOrderError == "Sort Order is a required field.")
        #expect(vm.measure1StartError == "Measure 1 Start must be empty or a valid time string.")
    }

    // MARK: - Source group behavior

    @Test("sourceGroupString can be set to existing group")
    func sourceGroupStringSetsExistingGroup() throws {
        let vm = try makeViewModel(sourceGroupName: "Group A")

        vm.sourceGroupString = "Group A"

        #expect(vm.sourceGroup != nil)
        #expect(vm.sourceGroup?.primitiveName == "Group A")
    }

    @Test("sourceGroupString empty clears source group")
    func sourceGroupStringEmptyClearsGroup() throws {
        let vm = try makeViewModel(sourceGroupName: "Group A")

        vm.sourceGroupString = ""

        #expect(vm.sourceGroup == nil)
        #expect(vm.sourceGroupString == "")
    }

    // MARK: - Save

    @Test("save succeeds when state is valid")
    func saveSucceedsWhenStateIsValid() throws {
        let fixture = try makeFixture(name: "Original", sortOrder: 3, bpm: 90)
        let vm = SourceEditView.ViewModel(
            source: fixture.source,
            collection: fixture.collection,
            context: fixture.context
        )

        vm.name = "Updated Name"
        vm.bpmString = "120"
        vm.sortOrderString = "8"
        vm.measure1StartString = "00:00:10"
        vm.isFavorite = true
        vm.notes = "Changed"

        let result = try vm.save()

        #expect(result == true)
        #expect(fixture.source.primitiveName == "Updated Name")
        #expect(fixture.source.media.bpm == 120)
        #expect(fixture.source.sortOrder == 8)
        #expect(fixture.source.measure1Start == 10.0)
        #expect(fixture.source.isFavorite == true)
        #expect(fixture.source.notes == "Changed")
    }

    @Test("save throws and leaves model untouched when state is invalid")
    func saveThrowsOnInvalidState() throws {
        let fixture = try makeFixture(name: "Original", sortOrder: 3, bpm: 90)
        let vm = SourceEditView.ViewModel(
            source: fixture.source,
            collection: fixture.collection,
            context: fixture.context
        )

        vm.name = ""
        vm.bpmString = "abc"
        vm.sortOrderString = ""

        #expect(throws: Error.self) {
            _ = try vm.save()
        }

        #expect(fixture.source.primitiveName == "Original")
        #expect(fixture.source.media.bpm == 90)
        #expect(fixture.source.sortOrder == 3)
    }
}
