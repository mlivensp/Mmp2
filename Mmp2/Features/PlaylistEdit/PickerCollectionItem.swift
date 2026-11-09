//
//  PickerCollectionItem.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/9/26.
//

import Foundation
import SwiftData

enum PickerCollectionItem: Identifiable {
    case collection(TopLevelCollection)

    var id: PersistentIdentifier {
        switch self {
        case .collection(let collection):
            return collection.id
        }
    }
}
