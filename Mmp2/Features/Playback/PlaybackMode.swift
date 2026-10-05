//
//  PlaybackMode.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation

enum PlaybackMode: CaseIterable {
    case constant
    case stepwise
    case bounce
}

extension PlaybackMode: Identifiable {
    var id: Self { self }
}

extension PlaybackMode {
    var label: String {
        switch self {
        case .constant: "Constant"
        case .stepwise: "Stepwise"
        case .bounce: "Bounce"
        }
    }
}
