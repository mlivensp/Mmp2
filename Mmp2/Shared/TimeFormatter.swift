//
//  TimeFormatter.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/27/26.
//

import Foundation
import AVFoundation

final class TimeFormatter {
    static let shared = TimeFormatter()

    private init() {}

    // MARK: - Formatting

    func string(from seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00.0" }

        let totalMilliseconds = Int((seconds * 1000).rounded())
        let hours = totalMilliseconds / 3_600_000
        let minutes = (totalMilliseconds % 3_600_000) / 60_000
        let secs = (totalMilliseconds % 60_000) / 1000
        let tenths = (totalMilliseconds % 1000) / 100

        if hours > 0 {
            return String(format: "%d:%02d:%02d.%d", hours, minutes, secs, tenths)
        } else {
            return String(format: "%d:%02d.%d", minutes, secs, tenths)
        }
    }

    func string(from time: CMTime) -> String {
        string(from: time.seconds)
    }

    // MARK: - Parsing

    func seconds(from string: String) throws -> Double {
        // Accept formats like:
        // "1:23.4", "00:12:04.25", "12.5", "90"
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { throw AppError.invalidTimeFormat }

        let parts = trimmed.split(separator: ":")

        var seconds: Double = 0

        switch parts.count {
        case 1:
            // "12.5"
            guard let value = Double(parts[0]) else {
                throw AppError.invalidTimeFormat
            }
            
            seconds = value

        case 2:
            // "1:23.4"
            guard let minutes = Double(parts[0]) else {
                throw AppError.invalidTimeFormat
            }
            
            guard let sec = Double(parts[1]) else {
                throw AppError.invalidTimeFormat
            }
            
            seconds = minutes * 60 + sec

        case 3:
            // "00:12:04.25"
            guard let hours = Double(parts[0]) else {
                throw AppError.invalidTimeFormat
            }
            guard let minutes = Double(parts[1]) else {
                throw AppError.invalidTimeFormat
            }
            guard let sec = Double(parts[2]) else {
                throw AppError.invalidTimeFormat
            }
            seconds = hours * 3600 + minutes * 60 + sec

        default:
            throw AppError.invalidTimeFormat
        }

        return seconds
    }
}
