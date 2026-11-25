//
//  Importer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import Foundation
import OSLog
import SwiftData
//import SwiftUI

@dynamicMemberLookup
struct JSON: RandomAccessCollection {
    var jsonValue: Any?
    
    init(string: String) throws {
        let dataString = Data(string.utf8)
        jsonValue = try JSONSerialization.jsonObject(with: dataString)
    }
    
    init(value: Any?) {
        self.jsonValue = value
    }
    
    var optionalBool: Bool? {
        jsonValue as? Bool
    }
    
    var optionalDouble: Double? {
        jsonValue as? Double
    }
    
    var optionalInt: Int? {
        jsonValue as? Int
    }
    
    var optionalInt64: Int64? {
        jsonValue as? Int64
    }
    
    var optionalString: String? {
        jsonValue as? String
    }
    
    var optionalDate: Date? {
        if let stringValue = optionalString, let date = try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(stringValue) {
            return date
        }
        
        return nil
    }
    
    var optionalArray: [JSON]? {
        let converted = jsonValue as? [Any]
        return converted?.map { JSON(value: $0) }
    }
    
    var optionalDictionary: [String: JSON]? {
        let converted = jsonValue as? [String: Any]
        return converted?.mapValues { JSON(value: $0) }
    }
    
    var bool: Bool {
        optionalBool ?? false
    }
    
    var double: Double {
        optionalDouble ?? 0
    }
    
    var int: Int {
        optionalInt ?? 0
    }
    
    var int64: Int64 {
        optionalInt64 ?? 0
    }
    
    var string: String {
        optionalString ?? ""
    }
    
    var date: Date {
        optionalDate ?? Date()
    }
    
    var array: [JSON] {
        optionalArray ?? []
    }
    
    var dictionary: [String: JSON] {
        optionalDictionary ?? [:]
    }
    
    subscript(index: Int) -> JSON {
        optionalArray?[index] ?? JSON(value: nil)
    }
    
    subscript(key: String) -> JSON {
        optionalDictionary?[key] ?? JSON(value: nil)
    }
    
    subscript(dynamicMember key: String) -> JSON {
        optionalDictionary?[key] ?? JSON(value: nil)
    }
    
    var startIndex: Int { array.startIndex }
    var endIndex: Int { array.endIndex }
}

struct Importer {
    fileprivate func importCollections(in modelContext: ModelContext, _ collections: JSON) -> ([Int: Source], [Int: Clip]) {
        var sourceMap: [Int: Source] = [:]
        var clipMap: [Int: Clip] = [:]
        for collectionData in collections.array {
            let collection = collectionData.collection
            let name = collection.name.string
            let notes = collection.notes.optionalString
            let mediaCollection = MediaCollection(name: name, notes: notes)
            modelContext.insert(mediaCollection)
            
            let sourceGroups = importSourceGroups(modelContext: modelContext, collectionData.groups.array, mediaCollection)
            let (collectionSourceMap, sourceClipMap) = importSources(modelContext: modelContext, sources: collectionData.sources.array, mediaCollection: mediaCollection, sourceGroups: sourceGroups)
            sourceMap = sourceMap + collectionSourceMap
            clipMap = clipMap + sourceClipMap
        }
        
        return (sourceMap, clipMap)
    }
    
    fileprivate func importSourceGroups(modelContext: ModelContext, _ groups: [JSON], _ mediaCollection: MediaCollection) -> [Int:SourceGroup] {
        var sourceGroups: [Int:SourceGroup] = [:]
        for group in groups {
            let id = group.sourceGroupId.int
            let name = group.name.string
            let sortOrder = group.sortOrder.int
            let isExpanded = group.isExpanded.bool
            let sourceGroup = SourceGroup(name: name, sortOrder: sortOrder, isExpanded: isExpanded, mediaCollection: mediaCollection)
            modelContext.insert(sourceGroup)
            mediaCollection.sourceGroups.append(sourceGroup)
            sourceGroups[id] = sourceGroup
        }
        
        return sourceGroups
    }
    
    fileprivate func importSources(modelContext: ModelContext, sources: [JSON], mediaCollection: MediaCollection, sourceGroups: [Int: SourceGroup]) -> ([Int: Source], [Int: Clip]) {
        var sourceMap: [Int:Source] = [:]
        var clipMap: [Int:Clip] = [:]
        
        for sourceAggregate in sources {
            let playback = importPlayback(modelContext: modelContext, sourceAggregate.playback)
            
            let sourceData = sourceAggregate.source
            let id = sourceData.sourceId.int
            let name = sourceData.name.string
            let sortOrder = sourceData.sortOrder.int
            let measure1Start: Double?
            
            if let measure1StartValue = sourceData.measure1Start.optionalString {
                measure1Start = try? TimeFormatter.shared.seconds(from: measure1StartValue)
            } else {
                measure1Start = nil
            }

            let isFavorite = sourceData.isFavorite.bool
            let isExpanded = sourceData.isExpanded.bool
            let bpm = sourceData.bpm.optionalInt
            let path = sourceData.path.string
            let duration: TimeInterval
            
            if let durationValue = timeInterval(from: sourceData.duration.string) {
                duration = durationValue
            } else {
                duration = .zero
            }
            
            // always import pathIsValid as false
//            let pathIsValid = sourceData.pathIsValid.bool
            let isArchived = sourceData.isArchived.bool
            let lastPlayed = sourceData.lastPlayed.optionalDate
            let numberTimesPlayed = sourceData.numberTimesPlayed.int
            let notes = sourceData.notes.optionalString
            var sourceGroup: SourceGroup?
            
            if let sourceGroupId = sourceData.sourceGroupId.optionalInt {
                sourceGroup = sourceGroups[sourceGroupId]
            }
            
            let source = Source(
                name: name,
                sortOrder: sortOrder,
                measure1Start: measure1Start,
                isFavorite: isFavorite,
                isExpanded: isExpanded,
                bpm: bpm,
                path: path,
                bookmark: nil,
                duration: duration,
                pathIsValid: false,
                isArchived: isArchived,
                lastPlayed: lastPlayed,
                numberTimesPlayed: numberTimesPlayed,
                notes: notes,
                mediaCollection: mediaCollection,
                playback: playback,
                sourceGroup: sourceGroup)
            modelContext.insert(source)
            source.mediaCollection = mediaCollection
            
            let clipsForSource = importClips(modelContext: modelContext, sourceAggregate.clips.array, source: source)
            clipMap = clipMap + clipsForSource
            sourceMap[id] = source
        }
        
        return (sourceMap, clipMap)
    }
    
    fileprivate func importClips(modelContext: ModelContext, _ clips: [JSON], source: Source) -> [Int:Clip] {
        var result: [Int:Clip] = [:]
        for clipAggregate in clips {
            let playback = importPlayback(modelContext: modelContext, clipAggregate.playback)
            let clipData = clipAggregate.clip
            let id = clipData.clipId.int
            let name = clipData.name.string
            
            let startTime = clipData.startTime.string
            let startSeconds = (try? TimeFormatter.shared.seconds(from: startTime)) ?? 0
            let endTime = clipData.endTime.string
            let endSeconds = (try? TimeFormatter.shared.seconds(from: endTime)) ?? 0
            
            let startMeasure = clipData.startMeasure.optionalInt
            let endMeasure = clipData.endMeasure.optionalInt
            let isFavorite = clipData.isFavorite.bool
            let bpm = clipData.bpm.optionalInt
            let duration: TimeInterval
            
            if let durationValue = timeInterval(from: clipData.duration.string) {
                duration = durationValue
            } else {
                duration = .zero
            }
            
            let lastPlayed = clipData.lastPlayed.optionalDate
            let numberTimesPlayed = clipData.numberTimesPlayed.int
            
            let notes = clipData.notes.optionalString
            let clip = Clip(
                name: name,
                startSeconds: startSeconds,
                endSeconds: endSeconds,
                startMeasure: startMeasure,
                endMeasure: endMeasure,
                isFavorite: isFavorite,
                bpm: bpm,
                duration: duration,
                lastPlayed: lastPlayed,
                numberTimesPlayed: numberTimesPlayed,
                notes: notes,
                source: source,
                playback: playback)
            modelContext.insert(clip)
            result[id] = clip
        }
        
        return result
    }
    
    fileprivate func importDuration(_ duration: String?) -> TimeInterval? {
        if let durationString = duration {
            if let durationComponents = parseISO8601Duration(durationString) {
                if let timespan = timeSpan(from: durationComponents) {
                    return timespan
                }
            }
        }
        
        return nil
    }
    
    private func importConstant(_ constantJson: JSON) -> PlaybackConstant {
        let value = constantJson["value"].int
        return PlaybackConstant(value: value)
    }
    
    private func importProgression(_ progressionJson: JSON) -> PlaybackProgression {
        let start = progressionJson.start.int
        let increment = progressionJson.increment.int
        let max = progressionJson["max"].int
        let timesToPlayStep = progressionJson.timesToPlayStep.int
        return PlaybackProgression(start: start, increment: increment, max: max, timesToPlayEach: timesToPlayStep)
    }
    
    private func importSequences(_ playbackSequenceJson: JSON) -> [PlaybackSequence] {
        var result: [PlaybackSequence] = []
        let sequencesJson = playbackSequenceJson.sequences.array
        for sequenceJson in sequencesJson {
            let playOrder = sequenceJson.playOrder.int
            let value = sequenceJson.value.int
            let timesToPlay = sequenceJson.timesToPlay.optionalInt
            let playbackSequence = PlaybackSequence.makeDraft(
                playOrder: playOrder,
                value: value,
                timesToPlay: timesToPlay
                )
            result.append(playbackSequence)
        }
        return result
    }
    
    func importPlayback(modelContext: ModelContext, _ playbackJson: JSON,) -> Playback {
        
        let playbackData = playbackJson.playback
        let timesToPlay = playbackData.timesToPlay.optionalInt
        
        var constant: PlaybackConstant?
        var progression: PlaybackProgression?
        var sequences: [PlaybackSequence]?
        
        if !(playbackJson.playbackConstant.jsonValue is NSNull) {
            constant = importConstant(playbackJson.playbackConstant)
        } else if !(playbackJson.playbackProgression.jsonValue is NSNull) {
            progression = importProgression(playbackJson.playbackProgression)
        } else if !(playbackJson.playbackSequence.jsonValue is NSNull) {
            sequences = importSequences(playbackJson.playbackSequence)
        } else {
            Logger.data.warning("missing Playback data")
        }
        
        let playback = Playback(timesToPlay: timesToPlay)
        playback.playbackConstant = constant
        playback.playbackProgression = progression
        playback.playbackSequences = sequences
        modelContext.insert(playback)
        return playback
    }
    
    
    fileprivate func importPlaylistItems(in modelContext: ModelContext,_ playlistMembersJson: JSON, sourceMap: [Int: Source], clipMap: [Int: Clip]) -> [PlaylistItem] {
        var result: [PlaylistItem] = []
        
        for playlistItemAggregate in playlistMembersJson.array {
            let playlistItemJson = playlistItemAggregate.playlistItem

            let source: Source?
            let clip: Clip?
            let playback: Playback?
            
            if let sourceId = playlistItemJson.sourceId.optionalInt {
                source = sourceMap[sourceId]
                clip = nil
            } else if let clipId = playlistItemJson.clipId.optionalInt {
                source = nil
                clip = clipMap[clipId]
            } else {
                continue
            }
            
            let playOrder = playlistItemJson.playOrder.int
            let secondsToDelayOverride = playlistItemJson.secondsToDelayOverride.optionalInt
            
            let playbackJson = playlistItemAggregate.playback
            
            if (playbackJson.jsonValue is NSNull) {
                playback = nil
            } else {
                playback = importPlayback(modelContext: modelContext, playbackJson)
            }

            let playlistItem = PlaylistItem(playOrder: playOrder, secondsToDelayOverride: secondsToDelayOverride, source: source, clip: clip, playback: playback)
            result.append(playlistItem)
        }
    
        return result
    }
    
    fileprivate func importPlaylists(in modelContext: ModelContext, _ playlists: JSON, groupLookups: [String:PlaylistGroup], sourceMap: [Int: Source], clipMap: [Int: Clip]) {
        for playlistAggregate in playlists.array {
            let playlistJson = playlistAggregate.playlist
            let name = playlistJson.name.string
            let shuffle = playlistJson.shuffle.bool
            let defaultSecondsToDelay = playlistJson.defaultSecondsToDelay.int
            let durationString = playlistJson.duration.string
            let duration = (try? TimeFormatter.shared.seconds(from: durationString)) ?? 0
            
            let timesToPlay = playlistJson.repeat.optionalInt
            let notes = playlistJson.notes.optionalString
            
            let playlist = Playlist(
                name: name,
                shuffle: shuffle,
                defaultSecondsToDelay: defaultSecondsToDelay,
                duration: duration,
                timesToPlay: timesToPlay,
                notes: notes)
            modelContext.insert(playlist)
            
            let groupNames = playlistAggregate.playlistGroupNames.array
            for groupNameJson in groupNames {
                let groupName = groupNameJson.string
                if let playlistGroup = groupLookups[groupName] {
                    let playlistGroupItem = PlaylistGroupItem(playlistGroup: playlistGroup, playlist: playlist)
                    modelContext.insert(playlistGroupItem)
                }
            }
            
            let playlistItemsJson = playlistAggregate.playlistItems
            let playlistItems = importPlaylistItems(in: modelContext, playlistItemsJson, sourceMap: sourceMap, clipMap: clipMap)
            _ = playlistItems.map { playlist.playlistItems.append($0) }
        }
    }
    
    fileprivate func importPlaylistGroups(in modelContext: ModelContext, _ playlistGroups: JSON) -> [String:PlaylistGroup] {
        var result: [String:PlaylistGroup] = [:]
        for playlistGroupJson in playlistGroups.array {
            let name = playlistGroupJson.name.string
            let playlistGroup = PlaylistGroup(name: name)
            modelContext.insert(playlistGroup)
            result[name] = playlistGroup
        }
        
        return result
    }
    
    fileprivate func purgeData(_ modelContext: ModelContext) {
        // Delete all PlaylistGroups
        let playlistGroupFetchDescriptor = FetchDescriptor<PlaylistGroup>()
        if let playlistGroups = try? modelContext.fetch(playlistGroupFetchDescriptor) {
            for playlistGroup in playlistGroups {
                modelContext.delete(playlistGroup)
            }
        }
        
        // Delete all Playlists
        let fetchDescriptor2 = FetchDescriptor<Playlist>()
        if let playlists = try? modelContext.fetch(fetchDescriptor2) {
            for playlist in playlists {
                modelContext.delete(playlist)
            }
        }
        
        // Delete all MediaCollections
        let fetchDescriptor = FetchDescriptor<MediaCollection>()
        if let collections = try? modelContext.fetch(fetchDescriptor) {
            for collection in collections {
                modelContext.delete(collection)
            }
        }
        
        // TODO: AppSettings
        // TODO: Backups
        // TODO: Version
    }
    
    @MainActor
    func importFromURL(_ url: URL, modelContext: ModelContext) throws {
        // TODO: errors need to be handled here
        guard url.startAccessingSecurityScopedResource() else {
            print("Failed to access security-scoped resource")
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        guard let data = try? String(contentsOf: url, encoding: .utf8) else { return }
        guard let json = try? JSON(string: data) else { return }
        
        purgeData(modelContext)
        let collectionsJson = json.collections
        let (sourceMap, clipMap) = importCollections(in: modelContext, collectionsJson)
        let playlistGroupsJson = json.playlistGroups
        let playlistGroupLookups = importPlaylistGroups(in: modelContext, playlistGroupsJson)
        let playlistJson = json.playlists
        importPlaylists(in: modelContext, playlistJson, groupLookups: playlistGroupLookups, sourceMap: sourceMap, clipMap: clipMap)
        
        
        // TODO: AppSettings
        // TODO: Backups
        // TODO: Playlists
        // TODO: Version
        //        appRootManager.currentRoot = .home
        try modelContext.save()
    }
}
//func format(dateComponents: DateComponents) -> String {
//    let calendar = Calendar.current
//    let formatter = DateFormatter()
//    formatter.dateFormat = "HH:mm:ss.SSSSSSSSS"
//
//    guard let date = calendar.date(from: dateComponents) else {
//        return ""
//    }
//
//    return formatter.string(from: date)
//}
//
func timeInterval(from timeString: String) -> TimeInterval? {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSSSSSS"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    guard let date = formatter.date(from: timeString) else {
        return nil
    }
    
    return date.timeIntervalSinceReferenceDate
}

func parseTime(_ string: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSSSSSS"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter.date(from: string)
}

func parseISO8601Duration(_ duration: String) -> DateComponents? {
    let pattern = #"^P(?:(?<years>\d+)Y)?(?:(?<months>\d+)M)?(?:(?<weeks>\d+)W)?(?:(?<days>\d+)D)?(?:T(?:(?<hours>\d+)H)?(?:(?<minutes>\d+)M)?(?:(?<seconds>\d+)(?:\.(?<fractionalSeconds>\d+))?S)?)?$"#
    
    // Create the regular expression
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        print("Invalid regex pattern")
        return nil
    }
    
    // Perform the matching
    let nsRange = NSRange(duration.startIndex..<duration.endIndex, in: duration)
    guard let match = regex.firstMatch(in: duration, range: nsRange) else {
        print("No matches found")
        return nil
    }
    
    // Initialize DateComponents
    var components = DateComponents()
    
    // Helper function to extract integer values from named capture groups
    func getInt(from name: String) -> Int? {
        let nsRange = match.range(withName: name)
        if nsRange.location != NSNotFound, let range = Range(nsRange, in: duration) {
            return Int(duration[range])
        }
        return nil
    }
    
    // Helper function to extract Double values from named capture groups
    func getDouble(from name: String) -> Double? {
        let nsRange = match.range(withName: name)
        if nsRange.location != NSNotFound, let range = Range(nsRange, in: duration) {
            return Double(duration[range])
        }
        return nil
    }
    
    // Map captured groups to DateComponents
    components.year = getInt(from: "years")
    components.month = getInt(from: "months")
    let weeks = getInt(from: "weeks")
    components.day = getInt(from: "days")
    components.hour = getInt(from: "hours")
    components.minute = getInt(from: "minutes")
    
    // Handle seconds (including fractional)
    if let secondsValue = getDouble(from: "seconds") {
        let integerSeconds = Int(secondsValue)
        let fractionalSeconds = secondsValue - Double(integerSeconds)
        components.second = integerSeconds
        components.nanosecond = Int(fractionalSeconds * 1_000_000_000)
    }
    
    // Convert weeks to days and add to the day component
    if let weekCount = weeks {
        components.day = (components.day ?? 0) + weekCount * 7
    }
    
    return components
}

func timeSpan(from components: DateComponents) -> TimeInterval? {
    let calendar = Calendar.current
    
    // Creating a reference date, such as the Unix epoch (1970-01-01)
    let referenceDate = Date(timeIntervalSince1970: 0)
    
    // Using the calendar to calculate the date by adding DateComponents to the reference date
    if let date = calendar.date(byAdding: components, to: referenceDate) {
        // Calculating the TimeInterval by finding the difference between the new date and the reference date
        let timeSpan = date.timeIntervalSince(referenceDate)
        return timeSpan
    } else {
        return nil
    }
}

func +<K, V>(lhs: [K: V], rhs: [K: V]) -> [K: V] {
    return lhs.merging(rhs) { _, _ in
        fatalError("Duplicate key")
    }
}
