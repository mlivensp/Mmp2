//
//  ClipSection.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/13/26.
//

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
        ForEach(sortedClips) { clip in
            ClipRow(clip: clip) { clp in
                appRootManager.editClip(clp, of: source)
            }
            .onTapGesture { onClipTapped(clip) }
        }
    }
}
