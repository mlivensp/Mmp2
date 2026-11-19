//
//  Playback+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/4/26.
//

import Foundation
import SwiftData

extension Playback {
    func switchMode(
        to newMode: PlaybackMode,
        context: ModelContext
    ) {
        // Delete whichever submodel is NOT the new mode
        func deleteIfNeeded<T: PersistentModel>(_ current: inout T?) {
            if let old = current {
                context.delete(old)
                current = nil
            }
        }

        switch newMode {
        case .constant:
            deleteIfNeeded(&playbackProgression)
            deletePlaybackSequence(context: context)

            if playbackConstant == nil {
                let new = PlaybackConstant.makeDraft()
                playbackConstant = new
            }
            

        case .progression:
            deleteIfNeeded(&playbackConstant)
            deletePlaybackSequence(context: context)

            if playbackProgression == nil {
                let new = PlaybackProgression.makeDraft()
                playbackProgression = new
            }
        case .sequence:
            deleteIfNeeded(&playbackConstant)
            deleteIfNeeded(&playbackProgression)
        }
    }
    
    private func deletePlaybackSequence(context: ModelContext) {
        if let playbackSequences {
            for playbackSequence in playbackSequences {
                context.delete(playbackSequence)
            }
        }
    }
}

extension Playback {
    static func makeDraft(timesToPlay: Int? = 1) -> Playback {
        let playback = Playback(timesToPlay: timesToPlay)
        return playback
    }
}

extension PlaybackConstant {
    static func makeDraft() -> PlaybackConstant {
        PlaybackConstant(value: 100)
    }
}

extension PlaybackProgression {
    static func makeDraft() -> PlaybackProgression {
        PlaybackProgression(start: 80, increment: 2, max: 100, timesToPlayEach: 1)
    }
}

extension PlaybackSequence {
    static func makeDraft(
        playOrder: Int = 0,
        value: Int = 120,
        timesToPlay: Int? = 1
    ) -> PlaybackSequence {
        return PlaybackSequence(playOrder: playOrder, value: value, timesToPlay: timesToPlay)
    }
}
