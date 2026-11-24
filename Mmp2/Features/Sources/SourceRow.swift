//
//  SourceRow.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import SwiftUI

struct SourceRow: View {
    let source: Source
    let onEdit: (Source) -> Void

    var body: some View {
        Label {
            Text(source.primitiveName)
                .foregroundStyle(source.pathIsValid ? .primary : .secondary)
        } icon: {
            let systemName: String
            let color: Color
            
            if source.pathIsValid {
                if source.isFavorite {
                    systemName = "heart.fill"
                    color = .red
                } else {
                    systemName = "music.pages"
                    color = .primary
                }
            } else {
                systemName = "exclamationmark.triangle.fill"
                color = .yellow
            }
            
            return Image(systemName: systemName)
                .foregroundStyle(color)
//            Image(systemName: source.isFavorite ? "heart.fill" : "music.pages")
//                .foregroundStyle(source.isFavorite ? .red : .primary)
        }
        .contextMenu {
            Button {
                onEdit(source)
            } label: {
                Label("Edit Source", systemImage: "pencil")
            }
        }    }
}

//#Preview {
//    SourceRow()
//}
