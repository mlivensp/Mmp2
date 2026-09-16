//
//  Importer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import Foundation
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
    
    fileprivate func importCollections(in modelContext: ModelContext, _ collections: JSON) -> [MediaCollection] {
        var result: [MediaCollection] = []
        for collectionData in collections.array {
            let collection = collectionData.collection
            let name = collection.name.string
            let notes = collection.notes.optionalString
            let mediaCollection = MediaCollection(name: name, notes: notes)
            modelContext.insert(mediaCollection)
            
            let sourceGroups = importSourceGroups(modelContext: modelContext, collectionData.groups.array, mediaCollection)
            let sources = importSources(modelContext: modelContext, sources: collectionData.sources.array, mediaCollection: mediaCollection, sourceGroups: sourceGroups)
            print("Collection \(name) includes \(mediaCollection.sources?.count ?? -42) sources")
            result.append(mediaCollection)
        }
        
        return result
    }
    
    fileprivate func importSourceGroups(modelContext: ModelContext, _ groups: [JSON], _ mediaCollection: MediaCollection) -> [Int:SourceGroup] {
        var sourceGroups: [Int:SourceGroup] = [:]
        for group in groups {
            let id = group.sourceGroupId.int
            let name = group.name.string
            let sortOrder = group.sortOrder.int
            let sourceGroup = SourceGroup(name: name, sortOrder: sortOrder, mediaCollection: mediaCollection)
            modelContext.insert(sourceGroup)
            mediaCollection.sourceGroups?.append(sourceGroup)
            sourceGroups[id] = sourceGroup
        }
        
        return sourceGroups
    }
    
    fileprivate func importSources(modelContext: ModelContext, sources: [JSON], mediaCollection: MediaCollection, sourceGroups: [Int:SourceGroup]) -> [Int:Source] {
        var result: [Int:Source] = [:]
        for sourceAggregate in sources {
            let media = importMedia(modelContext: modelContext, sourceAggregate.media)
            let playback = importPlayback(modelContext: modelContext, sourceAggregate.playback)
            
            let sourceData = sourceAggregate.source
            let id = sourceData.sourceId.int
            let name = sourceData.name.string
            let sortOrder = sourceData.sortOrder.int
            let measure1Start = sourceData.measure1Start.date
            let isFavorite = sourceData.isFavorite.bool
            let notes = sourceData.notes.optionalString
            var sourceGroup: SourceGroup?
            if let sourceGroupId = sourceData.sourceGroupId.optionalInt {
                sourceGroup = sourceGroups[sourceGroupId]
            }
            
            let source = Source(name: name, sortOrder: sortOrder, measure1Start: measure1Start, isFavorite: isFavorite, notes: notes, media: media, playback: playback, sourceGroup: sourceGroup)
            modelContext.insert(source)
            source.mediaCollection = mediaCollection

            let clips = importClips(modelContext: modelContext, sourceAggregate.clips.array, source: source)
//            _ = clips.map { source.addToClips($0) }
            result[id] = source
        }
        
        return result
    }
    
    fileprivate func importClips(modelContext: ModelContext, _ clips: [JSON], source: Source) -> [Int:Clip] {
        var result: [Int:Clip] = [:]
        for clipAggregate in clips {
            let media = importMedia(modelContext: modelContext, clipAggregate.media)
            let playback = importPlayback(modelContext: modelContext, clipAggregate.playback)
            let clipData = clipAggregate.clip
            let id = clipData.Id.int
            let name = clipData.name.string
            let startTime = parseTime(clipData.startTime.string)
            let endTime = parseTime(clipData.endTime.string)
            let startMeasure = clipData.startMeasure.optionalInt
            let endMeasure = clipData.endMeasure.optionalInt
            let isFavorite = clipData.isFavorite.bool
            let notes = clipData.notes.optionalString
            let clip = Clip(source: source, name: name, startTime: startTime ?? Date.distantPast, endTime: endTime ?? Date.distantPast, startMeasure: startMeasure, endMeasure: endMeasure, isFavorite: isFavorite, notes: notes, media: media, playback: playback)
            modelContext.insert(clip)
            result[id] = clip
        }
        
        return result
    }
    
    

    fileprivate func importMedia(modelContext: ModelContext,_ mediaJson: JSON) -> Media {
        let path = mediaJson.path.string
        var mediaDuration = TimeInterval.zero
        
        if let duration = timeInterval(from: mediaJson.duration.string) {
            mediaDuration = duration
        }
        
        let isArchived = mediaJson.isArchived.bool
        let pathIsValid = false
        let numberTimesPlayed = mediaJson.numberTimesPlayed.int
        let lastPlayed = mediaJson.lastPlayed.optionalDate
        let media = Media(path: path, duration: mediaDuration, isArchived: isArchived, pathIsValid: pathIsValid, numberTimesPlayed: numberTimesPlayed, lastPlayed: lastPlayed)
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
    
    func importPlayback(modelContext: ModelContext, _ playbackJson: JSON, ) -> Playback {
        let playback = Playback()
        modelContext.insert(playback)
        
        let playbackData = playbackJson.playback
        let start = playbackData.startPlaybackRate.int
        let timesToPlay = playbackData.timesToPlayAtRate.optionalInt

        if playbackJson.bounce.value is NSNull {
            
            if let step = playbackData.step.optionalInt {
                let max = playbackData.maxRate.optionalInt
                let playbackStepwise = PlaybackStepwise(start: start, step: step, max: max ?? 100, timesToPlay: timesToPlay ?? 1, playback: playback)
            } else {
                let playbackConstant = PlaybackConstant(tempo: start, timesToPlay: timesToPlay, playback: playback)
            }
        } else {
            // TODO: import bounce
        }
        return playback
    }

    
    //    fileprivate func importPlaylistMembers(_ members: [JSON], _ context: NSManagedObjectContext, _ collections: [MmpCollection]) -> [PlaylistMember] {
    //        var result: [PlaylistMember] = []
    //        for memberJson in members {
    //            let member = PlaylistMember(context: context)
    //            member.sequence = Int32(memberJson.sequence.int)
    //            member.secondsToDelay = memberJson.secondsToDelay.optionalInt
    //            let collectionName = memberJson.collectionName.string
    //            let sourceName = memberJson.sourceName.string
    //            let clipName = memberJson.clipName.optionalString
    //
    //            if let collection = collections.first(where: { $0.name == collectionName } ) {
    //                if let source = collection.collectionSources.first(where: { $0.name == sourceName } ) {
    //                    if let clipName {
    //                        if let clip = source.sourceClips.first(where: { $0.name == clipName } ) {
    //                            member.clip = clip
    //                        }
    //                    } else {
    //                        member.source = source
    //                    }
    //                }
    //            }
    //
    //            let playbackJson = memberJson.playback
    //
    //            if !(playbackJson.value is NSNull) {
    //                member.playback = importPlayback(playbackJson, context)
    //            }
    //
    //            result.append(member)
    //        }
    //
    //        return result
    //    }
    //
    //    fileprivate func importPlaylists(_ playlists: JSON, _ context: NSManagedObjectContext, _ collections: [MmpCollection]) {
    //        for playlistJson in playlists.array {
    //            let playlist = Playlist(context: context)
    //            playlist.name = playlistJson.name.string
    //            playlist.shuffle = playlistJson.shuffle.bool
    //            playlist.defaultSecondsToDelay = playlistJson.defaultSecondsToDelay.optionalInt ?? 0
    //            var duration = ""
    //
    //            let durationString = playlistJson.duration.string
    //            if let durationComponents = parseISO8601Duration(durationString) {
    //                duration = format(dateComponents: durationComponents)
    //            }
    //
    //            playlist.duration = duration
    //            playlist.notes = playlistJson.notes.string
    //            let playlistMembers = importPlaylistMembers(playlistJson.members.array, context, collections)
    //            _ = playlistMembers.map { playlist.addToPlaylistMembers($0) }
    //        }
    //    }
    
    fileprivate func purgeData(_ modelContext: ModelContext) {
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
    func importFromURL(_ url: URL, modelContext: ModelContext) {
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
        let playOrderDictionary = importPlayOrders(in: modelContext,  playOrdersJson)
        let collectionsJson = json.collections
        let collections = importCollections(in: modelContext, collectionsJson)
        
        
        // TODO: AppSettings
        // TODO: Backups
        // TODO: Playlists
        // TODO: Version
        //        let playlist = json.playlists
        //        importPlaylists(playlist, dataController.container.viewContext, collections)
        //        appRootManager.currentRoot = .home
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
