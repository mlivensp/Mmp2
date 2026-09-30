//
//  PersistentModel+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/30/26.
//

import Foundation
import SwiftData

extension PersistentModel {
    var isNew: Bool {
        self.modelContext == nil
    }
}
