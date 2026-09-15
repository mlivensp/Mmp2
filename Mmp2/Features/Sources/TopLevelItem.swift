//
//  TopLevelItem.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import Foundation
import SwiftData

enum TopLevelItem: Identifiable, Hashable {
    case group(SourceGroup)
    case source(Source)

    var id: some Hashable {
        switch self {
        case .group(let g): return g.persistentModelID
        case .source(let s): return s.persistentModelID
        }
    }
}
