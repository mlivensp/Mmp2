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
    var value: Any?
    
    init(string: String) throws {
        let data = Data(string.utf8)
        value = try JSONSerialization.jsonObject(with: data)
    }
    
    init(value: Any?) {
        self.value = value
    }
    
    var optionalBool: Bool? {
        value as? Bool
    }
    
    var optionalDouble: Double? {
        value as? Double
    }
    
    var optionalInt: Int? {
        value as? Int
    }
    
    var optionalInt64: Int64? {
        value as? Int64
    }
    
    var optionalString: String? {
        value as? String
    }
    
    var optionalDate: Date? {
        if let stringValue = optionalString, let date = try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(stringValue) {
            return date
        }
        
        return nil
    }
    
    var optionalArray: [JSON]? {
        let converted = value as? [Any]
        return converted?.map { JSON(value: $0) }
    }
    
    var optionalDictionary: [String: JSON]? {
        let converted = value as? [String: Any]
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
    fileprivate func importPlayOrders(in modelContext: ModelContext, _ playOrders: JSON) -> [Int:PlayOrder] {
        var result: [Int:PlayOrder] = [:]
        for playOrderData in playOrders.array {
            let id = playOrderData.playOrderId.int
            let name = playOrderData.name.string
            let slowOrder = playOrderData.slowOrder.int
            let midOrder = playOrderData.midOrder.int
            let fastOrder = playOrderData.fastOrder.int
            let sortOrder = playOrderData.sortOrder.int
            let playOrder = PlayOrder(name: name, slowOrder: slowOrder, midOrder: midOrder, fastOrder: fastOrder, sortOrder: sortOrder)
            modelContext.insert(playOrder)
            result[id] = playOrder
        }
        
        return result
    }
    
    fileprivate func importCollections(in modelContext: ModelContext, _ collections: JSON, playOrderMap: [Int:PlayOrder]) -> ([Int: Source], [Int: Clip]) {
        var sourceMap: [Int: Source] = [:]
        var clipMap: [Int: Clip] = [:]
        for collectionData in collections.array {
            let collection = collectionData.collection
            let name = collection.name.string
            let notes = collection.notes.optionalString
            let mediaCollection = MediaCollection(name: name, notes: notes)
            modelContext.insert(mediaCollection)
            
            let sourceGroups = importSourceGroups(modelContext: modelContext, collectionData.groups.array, mediaCollection)
            let (collectionSourceMap, sourceClipMap) = importSources(modelContext: modelContext, sources: collectionData.sources.array, mediaCollection: mediaCollection, sourceGroups: sourceGroups, playOrderMap: playOrderMap)
            sourceMap = sourceMap + collectionSourceMap
            clipMap = clipMap + sourceClipMap
            print("Collection \(name) includes \(mediaCollection.sources.count) sources")
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
    
    fileprivate func importSources(modelContext: ModelContext, sources: [JSON], mediaCollection: MediaCollection, sourceGroups: [Int: SourceGroup], playOrderMap: [Int:PlayOrder]) -> ([Int: Source], [Int: Clip]) {
        var sourceMap: [Int:Source] = [:]
        var clipMap: [Int:Clip] = [:]
        
        for sourceAggregate in sources {
            let media = importMedia(modelContext: modelContext, sourceAggregate.media)
            let playback = importPlayback(modelContext: modelContext, sourceAggregate.playback, playOrderMap: playOrderMap)
            
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
            //            let measure1Start = sourceData.measure1Start.optionalDate
            let isFavorite = sourceData.isFavorite.bool
            let isExpanded = sourceData.isExpanded.bool
            let notes = sourceData.notes.optionalString
            var sourceGroup: SourceGroup?
            if let sourceGroupId = sourceData.sourceGroupId.optionalInt {
                sourceGroup = sourceGroups[sourceGroupId]
            }
            
            let source = Source(name: name, sortOrder: sortOrder, measure1Start: measure1Start, isFavorite: isFavorite, isExpanded: isExpanded, notes: notes, media: media, playback: playback, sourceGroup: sourceGroup)
            modelContext.insert(source)
            source.mediaCollection = mediaCollection
            
            let clipsForSource = importClips(modelContext: modelContext, sourceAggregate.clips.array, source: source, playOrderMap: playOrderMap)
            clipMap = clipMap + clipsForSource
            sourceMap[id] = source
        }
        
        return (sourceMap, clipMap)
    }
    
    fileprivate func importClips(modelContext: ModelContext, _ clips: [JSON], source: Source, playOrderMap: [Int:PlayOrder]) -> [Int:Clip] {
        var result: [Int:Clip] = [:]
        for clipAggregate in clips {
            let media = importMedia(modelContext: modelContext, clipAggregate.media)
            let playback = importPlayback(modelContext: modelContext, clipAggregate.playback, playOrderMap: playOrderMap)
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
            let notes = clipData.notes.optionalString
            let clip = Clip(source: source, name: name, startSeconds: startSeconds, endSeconds: endSeconds, startMeasure: startMeasure, endMeasure: endMeasure, isFavorite: isFavorite, notes: notes, media: media, playback: playback)
            modelContext.insert(clip)
            result[id] = clip
        }
        
        return result
    }
    
    fileprivate func importMedia(modelContext: ModelContext,_ mediaJson: JSON) -> Media {
        let bpm = mediaJson.bpm.optionalInt
        let path = mediaJson.path.string
        var mediaDuration = TimeInterval.zero
        
        if let duration = timeInterval(from: mediaJson.duration.string) {
            mediaDuration = duration
        }
        
        let isArchived = mediaJson.isArchived.bool
        let pathIsValid = false
        let numberTimesPlayed = mediaJson.numberTimesPlayed.int
        let lastPlayed = mediaJson.lastPlayed.optionalDate
        let media = Media(bpm: bpm, path: path, duration: mediaDuration, isArchived: isArchived, pathIsValid: pathIsValid, numberTimesPlayed: numberTimesPlayed, lastPlayed: lastPlayed)
        modelContext.insert(media)
        return media
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
    
    private func importStepwise(_ stepwiseJson: JSON) -> PlaybackStepwise {
        let start = stepwiseJson.start.int
        let step = stepwiseJson.step.int
        let max = stepwiseJson["max"].int
        let timesToPlayStep = stepwiseJson.timesToPlayStep.int
        return PlaybackStepwise(start: start, step: step, max: max, timesToPlayStep: timesToPlayStep)
    }
    
    private func importBounce(_ bounceJson: JSON, playOrderMap: [Int:PlayOrder]) -> PlaybackBounce {
        let slow = bounceJson.slow.int
        let timesToPlaySlow = bounceJson.timesToPlaySlow.int
        let mid = bounceJson.mid.int
        let timesToPlayMid = bounceJson.timesToPlayMid.int
        let fast = bounceJson.fast.int
        let timesToPlayFast = bounceJson.timesToPlayFast.int
        let playOrderId = bounceJson.playOrderId.int
        var playOrder = playOrderMap[playOrderId]
        
        if playOrder == nil {
            Logger.data.warning("Missing play order for id \(playOrderId)")
            playOrder = playOrderMap.first?.value
        }
        
        let playbackBounce = PlaybackBounce(slow: slow, timesToPlaySlow: timesToPlaySlow, mid: mid, timesToPlayMid: timesToPlayMid, fast: fast, timesToPlayFast: timesToPlayFast, playOrder: playOrder)
        return playbackBounce
    }
    
    func importPlayback(modelContext: ModelContext, _ playbackJson: JSON, playOrderMap: [Int:PlayOrder]) -> Playback {
        
        let playbackData = playbackJson.playback
        let timesToPlay = playbackData.timesToPlay.optionalInt
        
        var constant: PlaybackConstant?
        var stepwise: PlaybackStepwise?
        var bounce: PlaybackBounce?
        
        if !(playbackJson.playbackConstant.value is NSNull) {
            constant = importConstant(playbackJson.playbackConstant)
        } else if !(playbackJson.playbackStepwise.value is NSNull) {
            stepwise = importStepwise(playbackJson.playbackStepwise)
        } else if !(playbackJson.playbackBounce.value is NSNull) {
            bounce = importBounce(playbackJson.playbackBounce, playOrderMap: playOrderMap)
        } else {
            Logger.data.warning("missing Playback subrecord")
        }
        
        let playback = Playback(timesToPlay: timesToPlay)
        playback.playbackConstant = constant
        playback.playbackStepwise = stepwise
        playback.playbackBounce = bounce
        modelContext.insert(playback)
        return playback
    }
    
    
    fileprivate func importPlaylistMembers(in modelContext: ModelContext,_ playlistMembersJson: JSON, sourceMap: [Int: Source], clipMap: [Int: Clip], playOrderMap: [Int:PlayOrder]) -> [PlaylistItem] {
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
            
            let sequence = playlistItemJson.sequence.int
            let secondsToDelayOverride = playlistItemJson.secondsToDelayOverride.optionalInt
            
            let playbackJson = playlistItemAggregate.playback
            
            if (playbackJson.value is NSNull) {
                playback = nil
            } else {
                playback = importPlayback(modelContext: modelContext, playbackJson, playOrderMap: playOrderMap)
            }

            let playlistItem = PlaylistItem(sequence: sequence, secondsToDelayOverride: secondsToDelayOverride, source: source, clip: clip, playback: playback)
            result.append(playlistItem)
        }
    
        return result
    }
    
    fileprivate func importPlaylists(in modelContext: ModelContext, _ playlists: JSON, groupLookups: [String:PlaylistGroup], sourceMap: [Int: Source], clipMap: [Int: Clip], playOrderMap: [Int:PlayOrder]) {
        for playlistAggregate in playlists.array {
            let playlistJson = playlistAggregate.playlist
            let name = playlistJson.name.string
            let shuffle = playlistJson.shuffle.bool
            let defaultSecondsToDelay = playlistJson.defaultSecondsToDelay.int
            let durationString = playlistJson.duration.string
            let duration = (try? TimeFormatter.shared.seconds(from: durationString)) ?? 0
            
            let timesToRepeat = playlistJson.repeat.optionalInt
            let notes = playlistJson.notes.optionalString
            
            let playlist = Playlist(
                name: name,
                shuffle: shuffle,
                defaultSecondsToDelay: defaultSecondsToDelay,
                duration: duration,
                timesToRepeat: timesToRepeat,
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
            let playlistItems = importPlaylistMembers(in: modelContext, playlistItemsJson, sourceMap: sourceMap, clipMap: clipMap, playOrderMap: playOrderMap)
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
        
        // Delete all PlayOrders
        let fetchDescriptor3 = FetchDescriptor<PlayOrder>()
        if let playOrders = try? modelContext.fetch(fetchDescriptor3) {
            for playOrder in playOrders {
                modelContext.delete(playOrder)
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
        
        let playOrdersJson = json.playOrders
        let playOrderMap = importPlayOrders(in: modelContext,  playOrdersJson)
        let collectionsJson = json.collections
        let (sourceMap, clipMap) = importCollections(in: modelContext, collectionsJson, playOrderMap: playOrderMap)
        let playlistGroupsJson = json.playlistGroups
        let playlistGroupLookups = importPlaylistGroups(in: modelContext, playlistGroupsJson)
        let playlistJson = json.playlists
        importPlaylists(in: modelContext, playlistJson, groupLookups: playlistGroupLookups, sourceMap: sourceMap, clipMap: clipMap, playOrderMap: playOrderMap)
        
        
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
