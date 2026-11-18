//
//  PlayableItem.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/31/26.
//

import Foundation
import SwiftData

struct PlayableItem {
    let reference: PlayableReference
    let url: URL
    let title: String
    let start: TimeInterval?
    let end: TimeInterval?
    let bpm: Int?
    let playback: Playback
}
