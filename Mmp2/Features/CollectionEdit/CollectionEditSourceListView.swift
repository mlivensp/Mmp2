//
//  CollectionEditSourceListView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/6/26.
//

import SwiftUI

struct CollectionEditSourceListView: View {
    let sources: [Source]

    private var columns: [GridItem] = [
        GridItem(.flexible(), alignment: .leading),  // source name column
        GridItem(.flexible(), alignment: .leading)   // group name column
    ]

    var body: some View {
        Section("Sources") {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
                Text("Name")
                    .font(.headline)
                Text("Group")
                    .font(.headline)
                ForEach(sources) { source in
                    Text(source.primitiveName)

                    Text(source.sourceGroup?.primitiveName ?? "")
                }
            }
        }
    }
}

#Preview {
    CollectionEditSourceListView(sources: [])
}
