//
//  Models.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/4/26.
//

import CoreMedia
import Foundation
import SwiftData

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

@Model public class Backup {
    var backupDateTime: Date
    var path: String
    var notes: String?
    
    public init(backupDateTime: Date, path: String, notes: String? = nil) {
        self.backupDateTime = backupDateTime
        self.path = path
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
    var bpm: Int?
    var duration: Double
    var lastPlayed: Date?
    var numberTimesPlayed: Int
    var notes: String?
    
    var source: Source

    @Relationship(deleteRule: .cascade)
    var playback: Playback
    
    public init(
        name: String,
        startSeconds: Double,
        endSeconds: Double,
        startMeasure: Int?,
        endMeasure: Int?,
        isFavorite: Bool,
        bpm: Int?,
        duration: Double,
        lastPlayed: Date?,
        numberTimesPlayed: Int,
        notes: String?,
        source: Source,
        playback: Playback
    ) {
        self.primitiveName = name
        self.name_normalized = name.normalizedForSearch
        self.startSeconds = startSeconds
        self.endSeconds = endSeconds
        self.firstMeasure = startMeasure
        self.lastMeasure = endMeasure
        self.isFavorite = isFavorite
        self.notes = notes
        self.bpm = bpm
        self.duration = duration
        self.lastPlayed = lastPlayed
        self.numberTimesPlayed = numberTimesPlayed
        self.source = source
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

//@Model public class Media {
//    var source: Source?
//    var clip: Clip?
//    var bpm: Int?
//    var duration: Double
//    var path: String?
//    var pathIsValid: Bool
//    var lastPlayed: Date?
//    var numberTimesPlayed: Int
//    var isArchived: Bool
//    var bookmark: Data?
//
//    public init(
//        bpm: Int?,
//        path: String,
//        duration: Double = 0,
//        isArchived: Bool = false,
//        pathIsValid: Bool = true,
//        numberTimesPlayed: Int = 0,
//        lastPlayed: Date? = nil,
//        
//    ) {
//        self.bpm = bpm
//        self.path = path
//        self.duration = duration
//        self.isArchived = isArchived
//        self.pathIsValid = pathIsValid
//        self.numberTimesPlayed = numberTimesPlayed
//        self.lastPlayed = lastPlayed
//    }
//}

@Model public class MediaCollection {
    var primitiveName: String
    var name_normalized: String
    var notes: String?

    @Relationship(deleteRule: .cascade, inverse: \SourceGroup.mediaCollection)
    var sourceGroups: [SourceGroup] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Source.mediaCollection)
    var sources: [Source] = []
    
    public init(name: String, notes: String? = nil) {
        self.primitiveName = name
        self.name_normalized = name.normalizedForSearch
        self.notes = notes
    }
}

@Model public class Playback {
    var timesToPlay: Int?
    
    @Relationship(deleteRule: .cascade)
    var playbackConstant: PlaybackConstant?
    
    @Relationship(deleteRule: .cascade)
    var playbackProgression: PlaybackProgression?
    
    @Relationship(deleteRule: .cascade)
    var playbackSequences: [PlaybackSequence]?

    public init(timesToPlay: Int?) {
        // TODO: add constant and progression parameters
        self.timesToPlay = timesToPlay
    }
}

@Model public class PlaybackConstant {
    var value: Int
    
    init(value: Int) {
        self.value = value
    }
}

@Model public class PlaybackProgression {
    var start: Int
    var increment: Int
    var max: Int
    var timesToPlayEach: Int
    
    init(start: Int, increment: Int, max: Int, timesToPlayEach: Int) {
        self.start = start
        self.increment = increment
        self.max = max
        self.timesToPlayEach = timesToPlayEach
    }
}

@Model public class PlaybackSequence {
    var sequence: Int
    var value: Int
    var timesToPlay: Int?
    
    init(sequence: Int, value: Int, timesToPlay: Int? = nil) {
        self.sequence = sequence
        self.value = value
        self.timesToPlay = timesToPlay
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

// TODO: unclear why Identifiable needs to be here
@Model public class PlaylistGroup: Identifiable {
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

@Model public class Source {
    var primitiveName: String
    var name_normalized: String = ""
    var sortOrder: Int
    var measure1Start: Double?
    var isFavorite: Bool
    var bpm: Int?
    var duration: Double
    var lastPlayed: Date?
    var numberTimesPlayed: Int
    var path: String?
    var pathIsValid: Bool
    var bookmark: Data?
    var isExpanded: Bool
    var notes: String?
    
    @Relationship(deleteRule: .cascade, inverse: \Clip.source)
    var clips: [Clip] = []
    
    @Relationship(deleteRule: .cascade)
    var playback: Playback
    
    var mediaCollection: MediaCollection
    
    var sourceGroup: SourceGroup?
    
    
    public init(
        name: String,
        sortOrder: Int,
        measure1Start: Double?,
        isFavorite: Bool,
        isExpanded: Bool,
        notes: String?,
        bpm: Int?,
        duration: Double,
        lastPlayed: Date?,
        numberTimesPlayed: Int,
        path: String,
        pathIsValid: Bool,
        bookmark: Data?,
        mediaCollection: MediaCollection,
        playback: Playback,
        sourceGroup: SourceGroup?
    ) {
        self.primitiveName = name
        self.name_normalized = name.normalizedForSearch
        self.sortOrder = sortOrder
        self.measure1Start = measure1Start
        self.isFavorite = isFavorite
        self.isExpanded = isExpanded
        self.notes = notes
        self.bpm = bpm
        self.duration = duration
        self.lastPlayed = lastPlayed
        self.numberTimesPlayed = numberTimesPlayed
        self.path = path
        self.pathIsValid = pathIsValid
        self.bookmark = bookmark
        self.mediaCollection = mediaCollection
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
    var mediaCollection: MediaCollection
    
    public init(name: String, sortOrder: Int, isExpanded: Bool = false, mediaCollection: MediaCollection) {
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

