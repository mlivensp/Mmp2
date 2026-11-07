//
//  Collection+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/7/26.
//

import Foundation

extension MediaCollection {
    static func makeDraft(name: String = "") -> MediaCollection {
        return MediaCollection(name: name)
    }
}
