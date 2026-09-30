//
//  TimeFormatterTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 9/29/26.
//

import Testing
@testable import Mmp2

struct TimeFormatterTests {

    @Test func testSecondsFraction() async throws {
        let seconds = try TimeFormatter.shared.seconds(from: "13.8")
        #expect(seconds == 13.8)
    }
    
    @Test func testMinutesSecondsFraction() async throws {
        let seconds = try TimeFormatter.shared.seconds(from: "03:28.1")
        #expect(seconds == 208.1)
    }
    
    @Test func testHoursMinutesSecondsFraction() async throws {
        let seconds = try TimeFormatter.shared.seconds(from: "01:03:28.1")
        #expect(seconds == 3808.1)
    }

    @Test func testTooManyParts() async throws {
        #expect(throws: AppError.invalidTimeFormat) {
            let _ = try TimeFormatter.shared.seconds(from: "06:01:03:28.1")
        }
    }

    @Test func testNonNumericSecondsFraction() async throws {
        #expect(throws: AppError.invalidTimeFormat) {
            let _ = try TimeFormatter.shared.seconds(from: "2b.1")
        }
    }
}
