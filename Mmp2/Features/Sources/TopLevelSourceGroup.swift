//
//  TopLevelSourceGroup.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/13/26.
//

import Foundation
import OSLog
import SwiftData

final class TopLevelSourceGroup: Identifiable {
    let sourceGroup: SourceGroup
    let sources: [TopLevelSource]
    
    init(sourceGroup: SourceGroup, sources: [TopLevelSource]) {
        self.sourceGroup = sourceGroup
        self.sources = sources
    }
    
    var id: PersistentIdentifier {
        sourceGroup.persistentModelID
    }
    
    var sortOrder: Int {
        sourceGroup.sortOrder
    }
    
    var isExpanded: Bool {
        get { sourceGroup.isExpanded }
        set {
            sourceGroup.isExpanded = newValue
            Task {
                do {
                    try sourceGroup.modelContext?.save()
                } catch {
                    Logger.data.error("TopLevelSourceGroup.isExpanded.set - \(error.localizedDescription)")
                }
            }
        }
    }
}

extension TopLevelSourceGroup: Equatable {
    static func == (lhs: borrowing TopLevelSourceGroup, rhs: borrowing TopLevelSourceGroup) -> Bool {
        lhs.sourceGroup == rhs.sourceGroup
    }
}

extension TopLevelSourceGroup: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(sourceGroup)
    }
}
