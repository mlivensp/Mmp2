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

        case .source(let id):
            guard let source = self[id, as: Source.self] else {
                return
            }

            source.lastPlayed = .now
            source.numberTimesPlayed += 1

        case .clip(let id):
            guard let clip = self[id, as: Clip.self] else {
                return
            }

            clip.lastPlayed = .now
            clip.numberTimesPlayed += 1
        }

        try modelContext.save()
    }
}
