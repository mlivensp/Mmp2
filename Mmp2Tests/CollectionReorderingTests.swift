//
//  CollectionReorderingTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 11/7/26.
//

@testable import Mmp2
import Testing
import SwiftData

@MainActor
@Suite("Collection Reordering")
struct CollectionReorderingTests {
    @Test
    func moveGroupUp() {

        let groupA = makeGroup(
            name: "A",
            sortOrder: 1
        )

        let groupB = makeGroup(
            name: "B",
            sortOrder: 2
        )

        let rows: [CollectionRow] = [
            .group(groupA),
            .group(groupB)
        ]

        let service = CollectionReorderingService()

        service.moveUp(.group(groupB), topLevelRows: rows)

        #expect(groupA.sortOrder == 2)
        #expect(groupB.sortOrder == 1)
    }

    @Test
    func firstGroupCannotMoveUp() async throws {

        let groupA = makeGroup(
            name: "A",
            sortOrder: 1
        )

        let rows: [CollectionRow] = [
            .group(groupA)
        ]
        
        let service = CollectionReorderingService()
        service.moveUp(.group(groupA), topLevelRows: rows)

        #expect(groupA.sortOrder == 1)
    }
    
    @Test
    func lastGroupCannotMoveDown() async throws {

        let groupA = makeGroup(
            name: "A",
            sortOrder: 1
        )


        let rows: [CollectionRow] = [
            .group(groupA)
        ]
        
        let service = CollectionReorderingService()

        service.moveDown(.group(groupA), topLevelRows: rows)

        #expect(groupA.sortOrder == 1)
    }
    
    @Test
    func ungroupedSourceMovesAboveGroup() async throws {

        let group = makeGroup(
            name: "Group",
            sortOrder: 1
        )

        let source = makeSource(
            name: "Source",
            sortOrder: 2
        )

 
        let rows: [CollectionRow] = [
            .group(group),
            .ungroupedSource(source)
        ]
        
        let service = CollectionReorderingService()

        service.moveUp(.ungroupedSource(source), topLevelRows: rows)

        #expect(source.sortOrder == 1)
        #expect(group.sortOrder == 2)
    }
    
    @Test
    func ungroupedSourceMovesBelowGroup() async throws {

        let source = makeSource(
            name: "Source",
            sortOrder: 1
        )

        let group = makeGroup(
            name: "Group",
            sortOrder: 2
        )


        let rows: [CollectionRow] = [
            .ungroupedSource(source),
            .group(group)
        ]
        
        let service = CollectionReorderingService()

        service.moveDown(.ungroupedSource(source), topLevelRows: rows)

        #expect(source.sortOrder == 2)
        #expect(group.sortOrder == 1)
    }
    
    @Test
    func groupedSourceMovesUpWithinGroup() async throws {

        let group = makeGroup(
            name: "Group",
            sortOrder: 1
        )

        let source1 = makeSource(
            name: "1",
            sortOrder: 1,
            group: group
        )

        let source2 = makeSource(
            name: "2",
            sortOrder: 2,
            group: group
        )

        group.sources.append(contentsOf: [source1, source2])

        let rows: [CollectionRow] = [
            .group(group)
        ]
        
        let service = CollectionReorderingService()

        service.moveUp(.groupedSource(source2), topLevelRows: rows)

        #expect(group.sources.count == 2)
        #expect(source2.sortOrder == 1)
        #expect(source1.sortOrder == 2)
    }
    
    @Test
    func firstGroupedSourceCannotMoveUp() async throws {

        let group = makeGroup(
            name: "Group",
            sortOrder: 1
        )

        let source = makeSource(
            name: "1",
            sortOrder: 1,
            group: group
        )

        group.sources.append(source)

        let rows: [CollectionRow] = [
            .group(group)
        ]
        
        let service = CollectionReorderingService()

        service.moveUp(.groupedSource(source), topLevelRows: rows)

        #expect(source.sortOrder == 1)
    }
    
    @Test
    func lastGroupedSourceCannotMoveDown() async throws {

        let group = makeGroup(
            name: "Group",
            sortOrder: 1
        )

        let source = makeSource(
            name: "1",
            sortOrder: 1,
            group: group
        )

        group.sources.append(source)

        let rows: [CollectionRow] = [
            .group(group)
        ]
        
        let service = CollectionReorderingService()

        service.moveDown(.groupedSource(source), topLevelRows: rows)

        #expect(source.sortOrder == 1)
    }
    
    @Test
    func movingGroupedSourceDoesNotAffectGroupOrder() async throws {

        let groupA = makeGroup(
            name: "A",
            sortOrder: 1
        )

        let groupB = makeGroup(
            name: "B",
            sortOrder: 2
        )

        let source1 = makeSource(
            name: "1",
            sortOrder: 1,
            group: groupA
        )

        let source2 = makeSource(
            name: "2",
            sortOrder: 2,
            group: groupA
        )
        
        groupA.sources.append(contentsOf: [source1, source2])

        let rows: [CollectionRow] = [
            .group(groupA),
            .group(groupB)
        ]
        
        let service = CollectionReorderingService()

        service.moveUp(.groupedSource(source2), topLevelRows: rows)

        #expect (groupA.sources.count == 2)
        #expect(groupA.sortOrder == 1)
        #expect(groupB.sortOrder == 2)
    }
    
    @Test
    func moveGroupDownPastUngroupedSource() {

        let group = makeGroup(
            name: "Group A",
            sortOrder: 1
        )

        let source = makeSource(
            name: "Source A",
            sortOrder: 2
        )

        let rows: [CollectionRow] = [
            .group(group),
            .ungroupedSource(source)
        ]

        let service = CollectionReorderingService()

        service.moveDown(
            .group(group),
            topLevelRows: rows
        )

        #expect(group.sortOrder == 2)
        #expect(source.sortOrder == 1)
    }
    
    @Test
    func repeatedMoveUpProducesExpectedOrdering() async throws {
        let group1 = makeGroup(name: "GroupA", sortOrder: 1)
        let group2 = makeGroup(name: "GroupB", sortOrder: 2)
        let group3 = makeGroup(name: "GroupC", sortOrder: 3)

        let rows: [CollectionRow] = [
            .group(group1),
            .group(group2),
            .group(group3)
        ]
        
        let service = CollectionReorderingService()

        service.moveUp(.group(group3), topLevelRows: rows)
        service.moveUp(.group(group3), topLevelRows: rows)

        #expect(group3.sortOrder == 1)
    }
    
    // MARK: Helpers
    
    private func makeGroup(
        name: String,
        sortOrder: Int
    ) -> SourceGroup {

        SourceGroup(
            name: name,
            sortOrder: sortOrder
        )
    }

    private func makeSource(
        name: String,
        sortOrder: Int,
        group: SourceGroup? = nil
    ) -> Source {

        let media = Media.makeDraft()
        let playback = Playback.makeDraft()
        return Source(
            name: name,
            sortOrder: sortOrder,
            measure1Start: nil,
            isFavorite: false,
            isExpanded: false,
            notes: nil,
            media: media,
            playback: playback,
            sourceGroup: group
        )
    }
    
    private func makeViewModel(
        groups: [SourceGroup] = [],
        sources: [Source] = []
    ) throws -> CollectionEditView.ViewModel {

        let container = try ModelContainer(
            for:
                MediaCollection.self,
                Source.self,
                SourceGroup.self,
                Media.self,
                Playback.self,
            configurations: ModelConfiguration(
                isStoredInMemoryOnly: true
            )
        )

        let context = container.mainContext

        let collection = MediaCollection.makeDraft(
            name: "Test Collection"
        )

        context.insert(collection)

        for group in groups {
            context.insert(group)

            if !collection.sourceGroups.contains(group) {
                collection.sourceGroups.append(group)
            }
        }
        
        for source in sources {
            context.insert(source)

            if !collection.sources.contains(source) {
                collection.sources.append(source)
            }
        }

        return CollectionEditView.ViewModel(
            collection: collection,
            context: context
        )
    }}
