//
//  AppRootManager.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import Foundation
import OSLog
import SwiftUI

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
    
    enum AppRoot { case splash, home, play, playlistPlayer, playlistEditor, documents }
    enum AppCategory { case collections, playlists, favorites, recents }
    
    private init() { }
    
    // MARK: Navigation helpers
    
    /// Navigation stack contents for the home scene's detail column.
    var detailPath = NavigationPath()
    
    private func resetDetailPath() {
        Logger.navigation.info("resetDetailPath")
        detailPath = NavigationPath()
    }
    
    /// Called when the user picks a different collection: show its sources.
    func selectCollection(_ collection: MediaCollection?) {
        Logger.navigation.info("selectCollection - \(collection?.primitiveName ?? "<nil>")")
        selectedMediaCollection = collection
        resetDetailPath()
    }
    
    func editCollection(_ collection: MediaCollection) {
        Logger.navigation.info("editCollection - \(collection.primitiveName)")
        selectedMediaCollection = collection
        resetDetailPath()
        detailPath.append(DetailRoute.collectionEdit(collection))
    }
    
    func editSource(_ source: Source, in collection: MediaCollection) {
        Logger.navigation.info("editSource - \(source.primitiveName)")
        detailPath.append(DetailRoute.sourceEdit(source, collection))
    }
    
    func editClip(_ clip: Clip, of source: Source) {
        Logger.navigation.info("editClip - \(clip.primitiveName)")
        detailPath.append(DetailRoute.clipEdit(clip, source))
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
