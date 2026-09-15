//
//  Logger+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import OSLog

extension Logger {
    // 1. Define your app's main subsystem (usually your bundle ID)
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.bitpicker.Mmp2"

    // 2. Create distinct categories for different parts of your app
    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let data = Logger(subsystem: subsystem, category: "Data")
}
