//
//  TopLevelCollection.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/9/26.
//

import Foundation
import SwiftData

final class TopLevelCollection: Identifiable {
    let collection: MediaCollection

    init(collection: MediaCollection) {
        self.collection = collection
    }

    var id: PersistentIdentifier {
        collection.persistentModelID
    }
}
