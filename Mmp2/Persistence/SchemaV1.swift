//
//  SchemaV1.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import CoreMedia
import Foundation
import SwiftData

public enum SchemaV1: VersionedSchema {
    public static let versionIdentifier = Schema.Version(1, 0, 0)
    public static let models: [any PersistentModel.Type] = [
        Backup.self,
        MediaCollection.self,
        Clip.self,
        Media.self,
        Playback.self,
        PlaybackConstant.self,
        PlaybackStepwise.self,
        PlaybackBounce.self,
        PlayOrder.self,
        Playlist.self,
        PlaylistItem.self,
        AppSetting.self,
        Source.self,
        SourceGroup.self,
        Version.self
    ]
    
    static let schema = Schema(models)

}
