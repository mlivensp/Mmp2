//
//  AppErrors.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/18/26.
//

import Foundation

nonisolated enum AppError: Error, Equatable {
    case noMedia
    case invalidPlayback
    case invalidTimeFormat
    case attemptToSaveInvalidState(String)
    
//    static func == (lhs: AppError, rhs: AppError) -> Bool {
//            switch (lhs, rhs) {
//            case (.noMedia, .noMedia),
//                 (.invalidPlayback, .invalidPlayback),
//                 (.invalidTimeFormat, .invalidTimeFormat):
//                return true
//                
//            case let (.attemptToSaveInvalidState(a), .attemptToSaveInvalidState(b)):
//                return a == b
//
//            default:
//                return false
//            }
//        }
}
