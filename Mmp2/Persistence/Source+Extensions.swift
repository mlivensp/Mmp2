//
//  Source+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/6/26.
//

import Foundation

extension Source {
    var effectiveSortOrder: Int {
        (sourceGroup == nil ? sortOrder : sourceGroup?.sortOrder) ?? 0
    }
}
