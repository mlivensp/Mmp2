//
//  PlayableItem.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/31/26.
//

import Foundation

struct PlayableItem {
    let url: URL
    let title: String
    let start: TimeInterval?
    let end: TimeInterval?
    let bpm: Int?
    let playback: Playback
}
