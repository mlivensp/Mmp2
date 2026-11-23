//
//  SourceGroups+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/22/26.
//

import Foundation

extension SourceGroup {
    static func makeDraft(name: String = "", sortOrder: Int = 0, isExpanded: Bool = false, mediaCollection: MediaCollection) -> SourceGroup {
        SourceGroup(
            name: name,
            sortOrder: sortOrder,
            isExpanded: isExpanded,
            mediaCollection: mediaCollection)
    }
}
