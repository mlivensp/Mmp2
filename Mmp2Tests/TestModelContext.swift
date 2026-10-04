//
//  Persistence.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation
import SwiftData

@MainActor
struct TestModelContext {
    private let container: ModelContainer
    let context: ModelContext
    
    init() throws {
        let schema = SchemaV1.schema
        let config = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        container = try ModelContainer(
            for: schema,
            configurations: [config]
        )
        context = ModelContext(container)
    }
}
