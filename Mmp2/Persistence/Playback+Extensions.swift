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
                let new = PlaybackConstant.createNew()
                context.insert(new)
                playbackConstant = new
            }

        case .stepwise:
            deleteIfNeeded(&playbackConstant)
            deleteIfNeeded(&playbackBounce)

            if playbackStepwise == nil {
                let new = PlaybackStepwise.createNew()
                context.insert(new)
                playbackStepwise = new
            }

        case .bounce:
            deleteIfNeeded(&playbackConstant)
            deleteIfNeeded(&playbackStepwise)

            if playbackBounce == nil {
                let new = PlaybackBounce.createNew()
                context.insert(new)
                playbackBounce = new
            }
        }
    }
}

//extension Playback {
//    @MainActor
//    func switchMode(
//        to newMode: PlaybackMode,
//        context: ModelContext
//    ) {
//        // Delete old submodel if switching modes
//        if newMode != .constant, let old = playbackConstant {
//            context.delete(old)
//            playbackConstant = nil
//        }
//        if newMode != .stepwise, let old = playbackStepwise {
//            context.delete(old)
//            playbackStepwise = nil
//        }
//        if newMode != .bounce, let old = playbackBounce {
//            context.delete(old)
//            playbackBounce = nil
//        }
//
//        // Create the new one if needed
//        switch newMode {
//        case .constant:
//            if playbackConstant == nil {
//                playbackConstant = PlaybackConstant.createNew()
//            }
//        case .stepwise:
//            if playbackStepwise == nil {
//                playbackStepwise = PlaybackStepwise.createNew()
//            }
//        case .bounce:
//            if playbackBounce == nil {
//                playbackBounce = PlaybackBounce.createNew()
//            }
//        }
//    }
//}

extension PlaybackConstant {
    static func createNew() -> PlaybackConstant {
        PlaybackConstant(rate: 100, timesToPlay: nil)
    }
}

extension PlaybackStepwise {
    static func createNew() -> PlaybackStepwise {
        PlaybackStepwise(start: 80, step: 2, max: 100, timesToPlay: 1)
    }
}

extension PlaybackBounce {
    static func createNew() -> PlaybackBounce {
        PlaybackBounce(slowTempo: 90, timesToPlaySlowTempo: 1, midTempo: 100, timesToPlayMidTempo: 1, fastTempo: 110, timesToPlayFastTempo: 1, numberOfBounces: 1)
    }
}
