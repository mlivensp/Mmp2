//
//  TopLevelSource.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/13/26.
//

import Foundation
import OSLog
import SwiftData

final class TopLevelSource: Identifiable {
    let source: Source
    
    init(source: Source) {
        self.source = source
    }
    
    var id: PersistentIdentifier {
        source.persistentModelID
    }
    
    var sortOrder: Int {
        source.sortOrder
    }
    
    var isExpanded: Bool {
        get { source.isExpanded }
        set {
            source.isExpanded = newValue
            Task {
                do {
                    try source.modelContext?.save()
                } catch {
                    Logger.data.error("TopLevelSource.isExpanded.set - \(error.localizedDescription)")
                }
            }
        }
    }
}

extension TopLevelSource: Equatable {
    static func == (lhs: borrowing TopLevelSource, rhs: borrowing TopLevelSource) -> Bool {
        lhs.source == rhs.source
    }
}

extension TopLevelSource: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(source)
    }
}
