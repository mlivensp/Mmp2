//
//  PlaylistPlaybackState.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/9/26.
//

import Foundation

enum PlaylistPlaybackState {
    case countingDown(
        upcoming: PlayableItem,
        secondsRemaining: Int
    )

    case playing(
        current: PlayableItem
    )

    case finished
}
