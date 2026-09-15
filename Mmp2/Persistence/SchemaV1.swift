//
//  SchemaV1.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static let models: [any PersistentModel.Type] = [
        Backup.self,
        MediaCollection.self,
        Clip.self,
//        CurrentSelection.self,
        Media.self,
        Playback.self,
        Playlist.self,
        PlaylistItem.self,
        Setting.self,
        Source.self,
        SourceGroup.self,
        Version.self
    ]
    
    static let schema = Schema(models)

    @Model class Backup {
        var backupDateTime: Date
        var path: String
        var notes: String?
        
        public init(backupDateTime: Date, path: String, notes: String? = nil) {
            self.backupDateTime = backupDateTime
            self.path = path
        }
    }

    @Model class MediaCollection {
        var clipFolderPath: String?
        var name_normalized: String
        var notes: String?
        var pathIsValid: Bool
        var primitiveName: String
//        @Relationship(inverse: \CurrentSelection.collection) var selection: CurrentSelection?
        
        @Relationship(deleteRule: .cascade, inverse: \SourceGroup.mediaCollection)
        var sourceGroups: [SourceGroup]?
        
        @Relationship(deleteRule: .cascade, inverse: \Source.mediaCollection)
        var sources: [Source]?
        
        public init(name: String, clipFolderPath: String? = nil , pathIsValid: Bool = true, notes: String? = nil) {
            self.primitiveName = name
            self.name_normalized = name.normalizedForSearch
            self.pathIsValid = pathIsValid
        }
    }

    @Model class Clip {
        var primitiveName: String
        var name_normalized: String = ""
        var startTime: Date
        var endTime: Date
        var startMeasure: Int?
        var endMeasure: Int?
        var isFavorite: Bool
        var createClipFile: Bool? = false
        var clipCreationInProgress: Bool
        var notes: String?
        
        @Relationship(deleteRule: .cascade, inverse: \Media.clip)
        var media: Media
        
        @Relationship(deleteRule: .cascade, inverse: \Playback.clip)
        var playback: Playback?
        
        var source: Source?
        
        public init(source: Source?, name: String, startTime: Date, endTime: Date, startMeasure: Int?, endMeasure: Int?, isFavorite: Bool, media: Media) {
            self.source = source
            self.primitiveName = name
            self.name_normalized = name.normalizedForSearch
            self.startTime = startTime
            self.endTime = endTime
            self.startMeasure = startMeasure
            self.endMeasure = endMeasure
            self.isFavorite = isFavorite
            self.clipCreationInProgress = false
            self.media = media
        }
    }
    
//    @Model class CurrentSelection {
//        var category: String?
//        var clip: Clip?
//        var collection: MediaCollection?
//        var playlist: Playlist?
//        @Relationship(inverse: \Source.selection) var source: Source?
//        @Relationship(inverse: \SourceGroup.selection) var sourceGroup: SourceGroup?
//        
//        public init() {
//
//        }
//    }

    @Model class Media {
        var source: Source?
        var clip: Clip?
        var bpm: Int?
        var duration: Double
        var path: String?
        var pathIsValid: Bool
        var lastPlayed: Date?
        var numberTimesPlayed: Int
        var isArchived: Bool

        public init(
            path: String,
            duration: Double = 0,
            isArchived: Bool = false,
            pathIsValid: Bool = true,
            numberTimesPlayed: Int = 0,
            lastPlayed: Date? = nil,
            
        ) {
            self.path = path
            self.duration = duration
            self.isArchived = isArchived
            self.pathIsValid = pathIsValid
            self.numberTimesPlayed = numberTimesPlayed
            self.lastPlayed = lastPlayed
        }
    }

    @Model class Playback {
        var source: Source?
        var clip: Clip?
        var playlistItem: PlaylistItem?
        
        @Relationship(deleteRule: .cascade, inverse: \PlaybackConstant.playback)
        var playbackConstant: PlaybackConstant?
        
        @Relationship(deleteRule: .cascade, inverse: \PlaybackStepwise.playback)
        var playbackStepwise: PlaybackStepwise?
        
        @Relationship(deleteRule: .cascade, inverse: \PlaybackBounce.playback)
        var playbackBounce: PlaybackBounce?
        //        var clip: Clip?
//        @Relationship(inverse: \PlaylistItem.playback) var playlistMember: PlaylistItem?
//        @Relationship(inverse: \Source.playback) var source: Source?
        public init() {

        }
    }
    
    @Model class PlaybackConstant {
        var tempo: Int
        var timesToPlay: Int?
        var playback: Playback?
        
        init(tempo: Int, timesToPlay: Int? = nil, playback: Playback?) {
            self.tempo = tempo
            self.timesToPlay = timesToPlay
            self.playback = playback
        }
    }
    
    @Model class PlaybackStepwise {
        var start: Int
        var step: Int
        var max: Int
        var timesToPlay: Int
        var playback: Playback?
        
        init(start: Int, step: Int, max: Int, timesToPlay: Int, playback: Playback?) {
            self.start = start
            self.step = step
            self.max = max
            self.timesToPlay = timesToPlay
            self.playback = playback
        }
    }
    
    @Model class PlaybackBounce {
        var slowTempo: Int
        var timesToPlaySlowTempo: Int
        var midTempo: Int
        var timesToPlayMidTempo: Int
        var fastTempo: Int
        var timesToPlayFastTempo: Int
        var numberOfBounces: Int
        var playback: Playback?
        
        @Relationship(deleteRule: .cascade, inverse: \PlayOrder.playbackBounce)
        var playOrder: PlayOrder
        
        init(slowTempo: Int, timesToPlaySlowTempo: Int, midTempo: Int, timesToPlayMidTempo: Int, fastTempo: Int, timesToPlayFastTempo: Int, numberOfBounces: Int, playback: Playback?, playOrder: PlayOrder) {
            self.slowTempo = slowTempo
            self.timesToPlaySlowTempo = timesToPlaySlowTempo
            self.midTempo = midTempo
            self.timesToPlayMidTempo = timesToPlayMidTempo
            self.fastTempo = fastTempo
            self.timesToPlayFastTempo = timesToPlayFastTempo
            self.numberOfBounces = numberOfBounces
            self.playback = playback
            self.playOrder = playOrder
        }
    }
    
    @Model class PlayOrder {
        var name: String
        var slowOrder: Int
        var midOrder: Int
        var fastOrder: Int
        var playbackBounce: PlaybackBounce?
        
        init(name: String, slowORder: Int, midOrder: Int, fastOrder: Int, playbackBounce: PlaybackBounce?) {
            self.name = name
            self.slowOrder = slowORder
            self.midOrder = midOrder
            self.fastOrder = fastOrder
            self.playbackBounce = playbackBounce
        }
    }

    @Model class Playlist {
        var defaultSecondsToDelay32: Int32 = 5
        var duration: String
        var name_normalized: String?
        var notes: String?
        var primitiveName: String
        var shuffle: Bool
        @Relationship(deleteRule: .cascade, inverse: \PlaylistItem.playlist) var playlistItems: [PlaylistItem]?

        public init(duration: String, primitiveName: String, shuffle: Bool) {
            self.duration = duration
            self.primitiveName = primitiveName
            self.shuffle = shuffle

        }
        
    }

    @Model class PlaylistItem {
        var secondsToDelay32: Int32? = 0
        var sequence: Int32 = 0
        var clip: Clip?
        @Relationship(deleteRule: .cascade) var playback: Playback?
        var playlist: Playlist
//        @Relationship(inverse: \Source.playlistMember) var source: Source?
        public init(playlist: Playlist) {
            self.playlist = playlist

        }
        
    }

    @Model class Setting {
        var deleteOrphansOnStartup: Bool
        var fixInvalidPathErrors: Bool
        var startupPage: String
        var theme: String
        var validateStorageLocationsOnStartup: Bool

        public init(deleteOrphansOnStartup: Bool, fixInvalidPathErrors: Bool, startupPage: String, theme: String, validateStorageLocationsOnStartup: Bool) {
            self.deleteOrphansOnStartup = deleteOrphansOnStartup
            self.fixInvalidPathErrors = fixInvalidPathErrors
            self.startupPage = startupPage
            self.theme = theme
            self.validateStorageLocationsOnStartup = validateStorageLocationsOnStartup

        }
        
    }

    @Model class Source {
        var primitiveName: String
        var name_normalized: String = ""
        var sortOrder: Int
        var measure1Start: Date?
        var isFavorite: Bool
        var notes: String?
        
        @Relationship(deleteRule: .cascade, inverse: \Clip.source)
        var clips: [Clip]?
        
        @Relationship(deleteRule: .cascade, inverse: \Media.source)
        var media: Media
        
        @Relationship(deleteRule: .cascade, inverse: \Playback.source)
        var playback: Playback
        
        var mediaCollection: MediaCollection?
        var sourceGroup: SourceGroup?
        
        
        public init(name: String, sortOrder: Int, measure1Start: Date?, isFavorite: Bool, notes: String?, media: Media, playback: Playback, sourceGroup: SourceGroup?) {
            self.primitiveName = name
            self.name_normalized = name.normalizedForSearch
            self.sortOrder = sortOrder
            self.measure1Start = measure1Start
            self.isFavorite = isFavorite
            self.notes = notes
            self.media = media
            self.playback = playback
            self.sourceGroup = sourceGroup
        }
    }

    @Model class SourceGroup {
        var name_normalized: String
        var primitiveName: String
        var sortOrder: Int
        @Relationship(deleteRule: .nullify, inverse: \Source.sourceGroup)
        var sources: [Source]?
        
        var mediaCollection: MediaCollection?
        
        public init(name: String, sortOrder: Int, mediaCollection: MediaCollection?) {
            self.primitiveName = name
            self.name_normalized = name.normalizedForSearch
            self.sortOrder = sortOrder
            self.mediaCollection = mediaCollection
        }
    }

    @Model class Version {
        var dbVersion: Int32 = 0
        public init() {

        }
        
    }
}
