//
//  Models.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/4/26.
//

import CoreMedia
import Foundation
import SwiftData

@Model public class Backup {
    var backupDateTime: Date
    var path: String
    var notes: String?
    
    public init(backupDateTime: Date, path: String, notes: String? = nil) {
        self.backupDateTime = backupDateTime
        self.path = path
    }
}

@Model public class MediaCollection {
//    var clipFolderPath: String?
    var primitiveName: String
    var name_normalized: String
    var notes: String?
    var pathIsValid: Bool

    @Relationship(deleteRule: .cascade, inverse: \SourceGroup.mediaCollection)
    var sourceGroups: [SourceGroup] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Source.mediaCollection)
    var sources: [Source] = []
    
    public init(name: String, pathIsValid: Bool = true, notes: String? = nil) {
        self.primitiveName = name
        self.name_normalized = name.normalizedForSearch
        self.pathIsValid = pathIsValid
        self.notes = notes
    }
}

@Model public class Clip {
    var primitiveName: String
    var name_normalized: String = ""
    var startSeconds: Double
    var endSeconds: Double
    var firstMeasure: Int?
    var lastMeasure: Int?
    var isFavorite: Bool
    var createClipFile: Bool? = false
    var clipCreationInProgress: Bool
    var notes: String?
    
    @Relationship(deleteRule: .cascade, inverse: \Media.clip)
    var media: Media
    
    @Relationship(deleteRule: .cascade, inverse: \Playback.clip)
    var playback: Playback
    
    var source: Source?
    
    public init(source: Source?, name: String, startSeconds: Double, endSeconds: Double, startMeasure: Int?, endMeasure: Int?, isFavorite: Bool, notes: String?, media: Media, playback: Playback) {
        self.source = source
        self.primitiveName = name
        self.name_normalized = name.normalizedForSearch
        self.startSeconds = startSeconds
        self.endSeconds = endSeconds
        self.firstMeasure = startMeasure
        self.lastMeasure = endMeasure
        self.isFavorite = isFavorite
        self.notes = notes
        self.clipCreationInProgress = false
        self.media = media
        self.playback = playback
    }
    
    var startCMTime: CMTime {
        CMTime(seconds: startSeconds, preferredTimescale: 600)
    }

    var endCMTime: CMTime {
        CMTime(seconds: endSeconds, preferredTimescale: 600)
    }
    
    var startTimeString: String {
        TimeFormatter.shared.string(from: startSeconds)
    }

    var endTimeString: String {
        TimeFormatter.shared.string(from: endSeconds)
    }
}

@Model public class Media {
    var source: Source?
    var clip: Clip?
    var bpm: Int?
    var duration: Double
    var path: String?
    var pathIsValid: Bool
    var lastPlayed: Date?
    var numberTimesPlayed: Int
    var isArchived: Bool
    var bookmark: Data?

    public init(
        bpm: Int?,
        path: String,
        duration: Double = 0,
        isArchived: Bool = false,
        pathIsValid: Bool = true,
        numberTimesPlayed: Int = 0,
        lastPlayed: Date? = nil,
        
    ) {
        self.bpm = bpm
        self.path = path
        self.duration = duration
        self.isArchived = isArchived
        self.pathIsValid = pathIsValid
        self.numberTimesPlayed = numberTimesPlayed
        self.lastPlayed = lastPlayed
    }
}

@Model public class Playback {
    var source: Source?
    var clip: Clip?
    var playlistItem: PlaylistItem?
    
    @Relationship(deleteRule: .cascade, inverse: \PlaybackConstant.playback)
    var playbackConstant: PlaybackConstant?
    
    @Relationship(deleteRule: .cascade, inverse: \PlaybackStepwise.playback)
    var playbackStepwise: PlaybackStepwise?
    
    @Relationship(deleteRule: .cascade, inverse: \PlaybackBounce.playback)
    var playbackBounce: PlaybackBounce?
//        @Relationship(inverse: \PlaylistItem.playback) var playlistMember: PlaylistItem?
//        @Relationship(inverse: \Source.playback) var source: Source?
    public init() {

    }
}

@Model public class PlaybackConstant {
    var rate: Int
    var timesToPlay: Int?
    var playback: Playback?
    
    init(rate: Int, timesToPlay: Int? = nil, playback: Playback? = nil) {
        self.rate = rate
        self.timesToPlay = timesToPlay
        self.playback = playback
    }
}

@Model public class PlaybackStepwise {
    var start: Int
    var step: Int
    var max: Int
    var timesToPlay: Int
    var playback: Playback?
    
    init(start: Int, step: Int, max: Int, timesToPlay: Int, playback: Playback? = nil) {
        self.start = start
        self.step = step
        self.max = max
        self.timesToPlay = timesToPlay
        self.playback = playback
    }
}

@Model public class PlaybackBounce {
    var slowTempo: Int
    var timesToPlaySlowTempo: Int
    var midTempo: Int
    var timesToPlayMidTempo: Int
    var fastTempo: Int
    var timesToPlayFastTempo: Int
    var numberOfBounces: Int
    var playback: Playback?
    
    var playOrder: PlayOrder?
    
    init(slowTempo: Int, timesToPlaySlowTempo: Int, midTempo: Int, timesToPlayMidTempo: Int, fastTempo: Int, timesToPlayFastTempo: Int, numberOfBounces: Int, playOrder: PlayOrder? = nil, playback: Playback? = nil) {
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

@Model public class PlayOrder {
    var name: String
    var slowOrder: Int
    var midOrder: Int
    var fastOrder: Int
    var sortOrder: Int
    
    @Relationship(deleteRule: .deny, inverse: \PlaybackBounce.playOrder)
    var playbackBounce: [PlaybackBounce] = []
    
    init(name: String, slowOrder: Int, midOrder: Int, fastOrder: Int, sortOrder: Int) {
        self.name = name
        self.slowOrder = slowOrder
        self.midOrder = midOrder
        self.fastOrder = fastOrder
        self.sortOrder = sortOrder
    }
}

@Model public class Playlist {
    var primitiveName: String
    var shuffle: Bool
    var defaultSecondsToDelay: Int
    var duration: TimeInterval
    var timesToRepeat: Int?
    var notes: String?
    var name_normalized: String
    
    @Relationship(deleteRule: .cascade, inverse: \PlaylistItem.playlist) var playlistItems: [PlaylistItem] = []
    @Relationship(deleteRule: .cascade, inverse: \PlaylistGroupItem.playlist) var groups: [PlaylistGroupItem] = []

    public init(name: String, shuffle: Bool, defaultSecondsToDelay: Int, duration: TimeInterval, timesToRepeat: Int?, notes: String?) {
        self.primitiveName = name
        self.name_normalized = name.normalizedForSearch
        self.shuffle = shuffle
        self.defaultSecondsToDelay = defaultSecondsToDelay
        self.duration = duration
        self.timesToRepeat = timesToRepeat
        self.notes = notes
    }
}

@Model public class PlaylistGroup {
    var primitiveName: String
    var name_normalized: String
    var isExpanded: Bool
    @Relationship(deleteRule: .cascade, inverse: \PlaylistGroupItem.playlistGroup) var groupItems: [PlaylistGroupItem] = []
    
    init(name: String, isExpanded: Bool = false) {
        self.primitiveName = name
        self.name_normalized = name.normalizedForSearch
        self.isExpanded = isExpanded
    }
}

@Model public class PlaylistGroupItem {
    @Relationship var playlistGroup: PlaylistGroup
    @Relationship var playlist: Playlist
    
    init(playlistGroup: PlaylistGroup, playlist: Playlist) {
        self.playlistGroup = playlistGroup
        self.playlist = playlist
    }
}

@Model public class PlaylistItem {
    var sequence: Int = 0
    var secondsToDelayOverride: Int?
    @Relationship var source: Source?
    @Relationship var clip: Clip?
    @Relationship(deleteRule: .cascade) var playback: Playback?
    @Relationship var playlist: Playlist?

    init(sequence: Int, secondsToDelayOverride: Int? = nil, source: Source? = nil, clip: Clip? = nil, playback: Playback? = nil, playlist: Playlist? = nil) {
        self.sequence = sequence
        self.secondsToDelayOverride = secondsToDelayOverride
        self.source = source
        self.clip = clip
        self.playback = playback
        self.playlist = playlist
    }
}

@Model public class AppSetting {
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

@Model public class Source {
    var primitiveName: String
    var name_normalized: String = ""
    var sortOrder: Int
    var measure1Start: Double?
    var isFavorite: Bool
    var isExpanded: Bool
    var notes: String?
    
    @Relationship(deleteRule: .cascade, inverse: \Clip.source)
    var clips: [Clip] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Media.source)
    var media: Media
    
    @Relationship(deleteRule: .cascade, inverse: \Playback.source)
    var playback: Playback
    
    var mediaCollection: MediaCollection?
    var sourceGroup: SourceGroup?
    
    
    public init(name: String, sortOrder: Int, measure1Start: Double?, isFavorite: Bool, isExpanded: Bool, notes: String?, media: Media, playback: Playback, sourceGroup: SourceGroup?) {
        self.primitiveName = name
        self.name_normalized = name.normalizedForSearch
        self.sortOrder = sortOrder
        self.measure1Start = measure1Start
        self.isFavorite = isFavorite
        self.isExpanded = isExpanded
        self.notes = notes
        self.media = media
        self.playback = playback
        self.sourceGroup = sourceGroup
    }
}

@Model public class SourceGroup {
    var name_normalized: String
    var primitiveName: String
    var sortOrder: Int
    var isExpanded: Bool
    @Relationship(deleteRule: .nullify, inverse: \Source.sourceGroup)
    var sources: [Source] = []
    
    var mediaCollection: MediaCollection?
    
    public init(name: String, sortOrder: Int, isExpanded: Bool, mediaCollection: MediaCollection?) {
        self.primitiveName = name
        self.name_normalized = name.normalizedForSearch
        self.sortOrder = sortOrder
        self.isExpanded = isExpanded
        self.mediaCollection = mediaCollection
    }
}

@Model public class Version {
    var dbVersion: Int32 = 0
    public init() {
    }
}

