//
//  ClipRow.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/15/26.
//

import SwiftUI

struct ClipRow: View {
    let clip: Clip
    let onEdit: (Clip) -> Void
    
    var body: some View {
        Label {
            Text(clip.primitiveName)
                .foregroundStyle(clip.source.pathIsValid ? .primary : .secondary)
        } icon: {
            let systemName: String
            let color: Color
            
            if clip.source.pathIsValid {
                if clip.isFavorite {
                    systemName = "heart.fill"
                    color = .red
                } else {
                    systemName = "music.note"
                    color = .primary
                }
            } else {
                systemName = "exclamationmark.triangle.fill"
                color = .yellow
            }
            
            return Image(systemName: systemName)
                .foregroundStyle(color)
//            Image(systemName: clip.isFavorite ? "heart.fill" : "music.note")
//                .foregroundStyle(clip.isFavorite ? .red : .primary)
        }
        .contextMenu {
            Button {
                onEdit(clip)
            } label: {
                Label("Edit Clip", systemImage: "pencil")
            }
        }
    }
}

//#Preview {
//    ClipRow()
//}
