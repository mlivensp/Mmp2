//
//  ClipListView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/25/26.
//

import SwiftUI

struct ClipListView: View {
    let clips: [Clip]
    let onClipTapped: (Clip) -> Void
    
    var body: some View {
        List(clips) { clip in
            ClipListRow(clip: clip)
                .onTapGesture {
                    onClipTapped(clip)
                }
        }
    }
}

//#Preview {
//    ClipListView()
//}
