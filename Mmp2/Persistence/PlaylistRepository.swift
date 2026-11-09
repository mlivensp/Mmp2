//
//  PlaylistRepository.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/7/26.
//

import Foundation
import SwiftData

struct PlaylistRepository {
    let context: ModelContext

    func fetchAll() throws -> [Playlist] {
        let descriptor = FetchDescriptor<Playlist>(
            sortBy: [SortDescriptor(\.name_normalized)]
        )
        return try context.fetch(descriptor)
    }
}
