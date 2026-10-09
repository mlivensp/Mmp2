//
//  Media+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/6/26.
//

import Foundation
import SwiftData

extension Media {
    static func makeDraft() -> Media {
        let media = Media(bpm: nil, path: "")
        return media
    }
}
