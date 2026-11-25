//
//  RecentItem.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/17/26.
//

import Foundation
import SwiftData

struct RecentItem: Identifiable {
    let id: PersistentIdentifier
    let reference: PlayableReference
    let name: String
    let lastPlayed: Date
    let isFavorite: Bool
    
    init(reference: PlayableReference, name: String, lastPlayed: Date, isFavorite: Bool) {
        switch reference {
        case .source(let source):
            self.id = source.id
        case .clip(let clip):
            self.id = clip.id
        }
        
        self.reference = reference
        self.name = name
        self.lastPlayed = lastPlayed
        self.isFavorite = isFavorite
    }
}
