//
//  PlayHistoryService.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/16/26.
//

import Foundation
import SwiftData

@ModelActor
actor PlayHistoryService {

    func recordPlay(playableReference: PlayableReference
    ) throws {

        switch playableReference {

        case .source(let source):
            source.lastPlayed = .now
            source.numberTimesPlayed += 1

        case .clip(let clip):
            clip.lastPlayed = .now
            clip.numberTimesPlayed += 1
        }

        try modelContext.save()
    }
}
