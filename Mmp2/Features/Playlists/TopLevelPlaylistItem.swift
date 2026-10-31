//
//  TopLevelPlaylistItem.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/30/26.
//

import Foundation

enum TopLevelPlaylistItem: Identifiable, Hashable {
    case group(TopLevelPlaylistGroup)
    case playlist(TopLevelPlaylist)

    var id: some Hashable {
        switch self {
        case .group(let g): return g.id
        case .playlist(let p): return p.id
        }
    }
}

extension TopLevelPlaylistItem {
    var sortOrder: String {
        switch self {
        case .group(let g): return g.sortOrder
        case .playlist(let p): return p.sortOrder
        }
    }
}
