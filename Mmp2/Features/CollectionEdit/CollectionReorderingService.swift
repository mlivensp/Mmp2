//
//  CollectionReorderingService.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/7/26.
//

import Foundation


final class CollectionReorderingService {
//    private let topLevelRows: [CollectionRow]
//    
//    init(topLevelRows: [CollectionRow]) {
//        self.topLevelRows = topLevelRows
//    }
    
    private func orderedTopLevelRows(topLevelRows: [CollectionRow]) -> [CollectionRow] {
        topLevelRows.sorted {
            $0.sortOrder < $1.sortOrder
        }
    }
    
    func moveUp(_ selectedRow: CollectionRow, topLevelRows: [CollectionRow]) {
        switch selectedRow {

        case .group(let group):
            moveGroupUp(group, topLevelRows: topLevelRows)

        case .groupedSource(let source):
            moveGroupedSourceUp(source)
            
        case .ungroupedSource(let source):
            moveUngroupedSourceUp(source, topLevelRows: topLevelRows)
        }
    }

    func moveDown(_ selectedRow: CollectionRow, topLevelRows: [CollectionRow]) {
        switch selectedRow {

        case .group(let group):
            moveGroupDown(group, topLevelRows: topLevelRows)

        case .groupedSource(let source):
            moveGroupedSourceDown(source)
            
        case .ungroupedSource(let source):
            moveUngroupedSourceDown(source, topLevelRows: topLevelRows)
        }
    }
//    
//    private var orderedTopLevelRows: [CollectionRow] {
//        topLevelRows.sorted {
//            $0.sortOrder < $1.sortOrder
//        }
//    }
    
    private func moveUngroupedSourceUp(_ source: Source, topLevelRows: [CollectionRow]) {

        let rows = orderedTopLevelRows(topLevelRows: topLevelRows)

        guard let index = rows.firstIndex(where: {
            $0 == .ungroupedSource(source)
        }) else {
            return
        }

        guard index > 0 else {
            return
        }

        swapSortOrders(
            rows[index],
            rows[index - 1]
        )
    }

    private func moveUngroupedSourceDown(_ source: Source, topLevelRows: [CollectionRow]) {

        let rows = orderedTopLevelRows(topLevelRows: topLevelRows)

        guard let index = rows.firstIndex(where: {
            $0 == .ungroupedSource(source)
        }) else {
            return
        }

        guard index < rows.count - 1 else {
            return
        }

        swapSortOrders(
            rows[index],
            rows[index + 1]
        )
    }
    
    private func moveGroupedSourceUp(_ source: Source) {

        guard let group = source.sourceGroup else {
            return
        }

        let sources = group.sources
            .sorted { $0.sortOrder < $1.sortOrder }

        guard let index = sources.firstIndex(of: source) else {
            return
        }

        guard index > 0 else {
            return
        }

        let previous = sources[index - 1]

        let temp = source.sortOrder
        source.sortOrder = previous.sortOrder
        previous.sortOrder = temp
    }
    
    private func moveGroupedSourceDown(_ source: Source) {

        guard let group = source.sourceGroup else {
            return
        }

        let sources = group.sources
            .sorted { $0.sortOrder < $1.sortOrder }

        guard let index = sources.firstIndex(of: source) else {
            return
        }

        guard index < sources.count - 1 else {
            return
        }

        let next = sources[index + 1]

        let temp = source.sortOrder
        source.sortOrder = next.sortOrder
        next.sortOrder = temp
    }

    private func moveGroupUp(_ group: SourceGroup, topLevelRows: [CollectionRow]) {

        let rows = orderedTopLevelRows(topLevelRows: topLevelRows)

        guard let index = rows.firstIndex(where: {
            $0 == .group(group)
        }) else {
            return
        }

        guard index > 0 else {
            return
        }

        swapSortOrders(
            rows[index],
            rows[index - 1]
        )
    }
    
    private func moveGroupDown(_ group: SourceGroup, topLevelRows: [CollectionRow]) {

        let rows = orderedTopLevelRows(topLevelRows: topLevelRows)

        guard let index = rows.firstIndex(where: {
            $0 == .group(group)
        }) else {
            return
        }

        guard index < rows.count - 1 else {
            return
        }

        swapSortOrders(
            rows[index],
            rows[index + 1]
        )
    }
    
    private func swapSortOrders(
        _ lhs: CollectionRow,
        _ rhs: CollectionRow
    ) {
        let lhsSortOrder = lhs.sortOrder
        let rhsSortOrder = rhs.sortOrder

        switch lhs {
        case .group(let group):
            group.sortOrder = rhsSortOrder

        case .groupedSource:
            return

        case .ungroupedSource(let source):
            source.sortOrder = rhsSortOrder
        }

        switch rhs {
        case .group(let group):
            group.sortOrder = lhsSortOrder

        case .groupedSource:
            return

        case .ungroupedSource(let source):
            source.sortOrder = lhsSortOrder
        }
    }
}
