//
//  TopLevelItem.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import Foundation
import SwiftData

enum TopLevelItem: Identifiable, Hashable {
    case group(TopLevelSourceGroup)
    case source(TopLevelSource)

    var id: some Hashable {
        switch self {
        case .group(let g): return g.id
        case .source(let s): return s.id
        }
    }
}

extension TopLevelItem: SortableSource {
    var sortOrder: Int {
        switch self {
        case .group(let g): return g.sortOrder
        case .source(let s): return s.sortOrder
        }
    }
}
