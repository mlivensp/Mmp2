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
import SwiftUI   // needed for NavigationPath-style usage; Foundation is not enough for some APIs

enum DetailRoute: Hashable {
    case collectionEdit(MediaCollection)
    case sourceEdit(Source, MediaCollection)
    case clipEdit(Clip, Source)
}

@Observable
final class AppRootManager {
    static let shared = AppRootManager()

    var currentRoot: AppRoot = .splash
    var selectedCategory: AppCategory = .collections

    var selectedMediaCollection: MediaCollection?
    var selectedSource: Source?
    var selectedClip: Clip?

    /// Navigation stack contents for the home scene's detail column.
    var detailPath = NavigationPath()

    enum AppRoot { case splash, home, play, playlistPlayer, playlistEditor, documents }
    enum AppCategory { case collections, playlists, favorites, recents }

    private init() { }

    // MARK: Navigation helpers

    /// Called when the user picks a different collection: show its sources.
    func selectCollection(_ collection: MediaCollection?) {
        selectedMediaCollection = collection
        detailPath.removeAll()
    }

    func editCollection(_ collection: MediaCollection) {
        selectedMediaCollection = collection
        detailPath = [.collectionEdit(collection)]
    }

    func editSource(_ source: Source, in collection: MediaCollection) {
        detailPath.append(.sourceEdit(source, collection))
    }

    func editClip(_ clip: Clip, of source: Source) {
        detailPath.append(.clipEdit(clip, source))
    }

    func play(source: Source) {
        selectedSource = source
        selectedClip = nil
        currentRoot = .play
    }

    func play(clip: Clip) {
        selectedSource = nil
        selectedClip = clip
        currentRoot = .play
    }
}
//@Observable
//final class AppRootManager {
//    static let shared = AppRootManager()
//    
//    var currentRoot: AppRoot = .splash {
//        didSet {
//            print("currentRoot set to \(currentRoot)")
//        }
//    }
//    
//    var selectedCategory = AppCategory.collections
//    var storedMediaCollection: MediaCollection?
//    var selectedMediaCollection: MediaCollection? {
//        get { storedMediaCollection }
//        set {
//            storedMediaCollection = newValue
//            Logger.data.info("selectedMediaCollection set to \(self.selectedMediaCollection?.primitiveName ?? "nil")")
//        }
//    }
//    
//    var selectedSource: Source? = nil
//    var selectedClip: Clip? = nil
//
//    enum AppRoot {
//        case splash
//        case home
//        case play
//        case playlistPlayer
//        case playlistEditor
//        case documents
//    }
//    
//    enum AppCategory {
//        case collections
//        case playlists
//        case favorites
//        case recents
//    }
//    
//    private init() { }
//}

extension AppRootManager: Equatable {
    static func == (lhs: AppRootManager, rhs: AppRootManager) -> Bool {
        lhs.currentRoot == rhs.currentRoot
    }
}

//extension AppRootManager.AppCategory: Equatable {
//    static func == (lhs: Self, rhs: Self) -> Bool {
//        switch (lhs, rhs) {
//        case (.collections, .collections),
//             (.playlists, .playlists),
//             (.favorites, .favorites),
//             (.recents, .recents):
//            return true
//
//        case let (.clipEdit(a,x), .clipEdit(b,y)):
//            return a.id == b.id && x.id == y.id
//
//        default:
//            return false
//        }
//    }
//}
