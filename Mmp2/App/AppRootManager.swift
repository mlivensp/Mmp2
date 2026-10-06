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
    
    var currentRoot: AppRoot = .splash {
        didSet {
            print("currentRoot set to \(currentRoot)")
        }
    }
    
    var selectedCategory = AppCategory.collections
    var storedMediaCollection: MediaCollection?
    var selectedMediaCollection: MediaCollection? {
        get { storedMediaCollection }
        set {
            storedMediaCollection = newValue
            Logger.data.info("selectedMediaCollection set to \(self.selectedMediaCollection?.primitiveName ?? "nil")")
        }
    }
    
    var selectedSource: Source? = nil
    var selectedClip: Clip? = nil

    enum AppRoot {
        case splash
        case home
        case play
        case playlistPlayer
        case playlistEditor
        case documents
    }
    
    enum AppCategory {
        case collections
        case playlists
        case favorites
        case recents
        case collectionEdit(collection: MediaCollection)
        case sourceEdit(source: Source, collection: MediaCollection)
        case clipEdit(clip: Clip, source: Source)
    }
    
    private init() { }
}

extension AppRootManager: Equatable {
    static func == (lhs: AppRootManager, rhs: AppRootManager) -> Bool {
        lhs.currentRoot == rhs.currentRoot
    }
}

extension AppRootManager.AppCategory: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.collections, .collections),
             (.playlists, .playlists),
             (.favorites, .favorites),
             (.recents, .recents):
            return true

        case let (.clipEdit(a,x), .clipEdit(b,y)):
            return a.id == b.id && x.id == y.id

        default:
            return false
        }
    }
}
