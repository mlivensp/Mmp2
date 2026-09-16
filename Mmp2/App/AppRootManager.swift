//
//  AppRootManager.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import Foundation
import OSLog

//import SwiftUI

//private struct AppRootManagerKey: EnvironmentKey {
//    static let defaultValue = AppRootManager.shared
//}
//
//extension EnvironmentValues {
//    var appRootManager: AppRootManager {
//        get { self[AppRootManagerKey.self] }
//        set { self[AppRootManagerKey.self] = newValue }
//    }
//}

@Observable
final class AppRootManager {
    static let shared = AppRootManager()
    
    var currentRoot: AppRoots = .splash {
        didSet {
            print("currentRoot set to \(currentRoot)")
        }
    }
    
    var selectedCategory = "Collections"
    var selectedMediaCollection: MediaCollection? {
        didSet {
            Logger.data.info("selectedMediaCollection set to \(self.selectedMediaCollection?.primitiveName ?? "nil")")
//            Logger.fluff.info(selectedMediaCollection?.primitiveName ?? "no collection")
        }
    }
    
    var selectedSource: Source? = nil
    var selectedClip: Clip? = nil

    enum AppRoots {
        case splash
        case home
        case play
        case playlistPlayer
        case playlistEditor
        case documents
    }
    
    private init() { }
}

extension AppRootManager: Equatable {
    static func == (lhs: AppRootManager, rhs: AppRootManager) -> Bool {
        lhs.currentRoot == rhs.currentRoot
    }
}
