//
//  CollectionSourceRow.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/6/26.
//

import Foundation
import SwiftData

enum CollectionRow: Identifiable, Equatable {
    case group(SourceGroup)
    case groupedSource(Source)
    case ungroupedSource(Source)

    var id: PersistentIdentifier {
        switch self {
        case .group(let group):
            return group.persistentModelID

        case .groupedSource(let source):
            return source.persistentModelID

        case .ungroupedSource(let source):
            return source.persistentModelID
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .group(let group):
            return group.sortOrder

        case .groupedSource(let source):
            return source.sortOrder

        case .ungroupedSource(let source):
            return source.sortOrder
        }
    }
}
