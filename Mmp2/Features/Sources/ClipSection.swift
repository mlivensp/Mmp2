//
//  ClipSection.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/13/26.
//

import OSLog
import SwiftUI

struct ClipSection: View {
    let clips: [Clip]
    let source: Source
    let onClipTapped: (Clip) -> Void
    let appRootManager: AppRootManager
    
    var body: some View {
        let sortedClips = clips.sorted(by: {
            if $0.startSeconds == $1.startSeconds {
                return $0.endSeconds < $1.endSeconds
            } else {
                return $0.startSeconds < $1.startSeconds
            }
        })
        
        let _ = dumpClips(sortedClips)
        
        ForEach(sortedClips) { clip in
            ClipRow(clip: clip) { clp in
                appRootManager.editClip(clp, of: source)
            }
            .onTapGesture { onClipTapped(clip) }
        }
    }
    
    func dumpClips(_ clips: [Clip]) {
        for clip in clips {
            Logger.data.info("\(clip.primitiveName) \(clip.startSeconds) \(clip.endSeconds)")
        }
    }
}
