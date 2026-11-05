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
            deleteIfNeeded(&playbackStepwise)
            deleteIfNeeded(&playbackBounce)

            if playbackConstant == nil {
                let new = PlaybackConstant.makeDraft()
                playbackConstant = new
            }

        case .stepwise:
            deleteIfNeeded(&playbackConstant)
            deleteIfNeeded(&playbackBounce)

            if playbackStepwise == nil {
                let new = PlaybackStepwise.makeDraft()
                playbackStepwise = new
            }

        case .bounce:
            deleteIfNeeded(&playbackConstant)
            deleteIfNeeded(&playbackStepwise)

            if playbackBounce == nil {
                let new = PlaybackBounce.makeDraft()
                playbackBounce = new
            }
        }
    }
}

extension Playback {
    static func makeDraft() -> Playback {
        let playback = Playback(timesToPlay: 1)
        return playback
    }
}

extension PlaybackConstant {
    static func makeDraft() -> PlaybackConstant {
        PlaybackConstant(value: 100)
    }
}

extension PlaybackStepwise {
    static func makeDraft() -> PlaybackStepwise {
        PlaybackStepwise(start: 80, step: 2, max: 100, timesToPlayStep: 1)
    }
}

extension PlaybackBounce {
    static func makeDraft() -> PlaybackBounce {
        PlaybackBounce(slow: 90, timesToPlaySlow: 1, mid: 100, timesToPlayMid: 1, fast: 110, timesToPlayFast: 1)
    }
}
