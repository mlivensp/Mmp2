//
//  PlayableItemKind.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/16/26.
//

import Foundation
import SwiftData

enum PlayableReference {
    case source(PersistentIdentifier)
    case clip(PersistentIdentifier)
}
