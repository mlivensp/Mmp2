//
//  MediaCollectionRepository.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/6/26.
//

import Foundation
import SwiftData

struct MediaCollectionRepository {
    let context: ModelContext

    func fetchAll() throws -> [MediaCollection] {
        let descriptor = FetchDescriptor<MediaCollection>(
            sortBy: [SortDescriptor(\.name_normalized)]
        )
        return try context.fetch(descriptor)
    }
}
