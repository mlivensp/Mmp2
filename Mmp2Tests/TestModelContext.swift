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
    static let shared = TestModelContext()

    private init() {}
    
    func makeInMemoryContainer() throws -> ModelContainer {
        let schema = SchemaV1.schema
        let config = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [config]
        )
    }
    
    func makeTestContext() throws -> ModelContext {
        let container = try makeInMemoryContainer()
        return ModelContext(container)
    }

}
