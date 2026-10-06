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
        } icon: {
            Image(systemName: source.isFavorite ? "heart.fill" : "music.pages")
                .foregroundStyle(source.isFavorite ? .red : .primary)
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
