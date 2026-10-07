//
//  CollectionEditSourceListView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/6/26.
//

import SwiftUI

struct CollectionEditSourceListView: View {
    let sources: [Source]
    let onEdit: (Source) -> Void
    
    private var columns: [GridItem] = [
        GridItem(.flexible(), alignment: .leading),  // source name column
        GridItem(.flexible(), alignment: .leading)   // group name column
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // --- Toolbar-like header ---
            HStack {
                Spacer()
                
                Text("Sources")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    // TODO: add source
                } label: {
                    Label("Add Source", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
                Text("Name")
                    .font(.headline)
                Text("Group")
                    .font(.headline)
                ForEach(sources) { source in
                    Text(source.primitiveName)
                        .contextMenu {
                            Button {
                                onEdit(source)
                            } label: {
                                Label("Edit Source", systemImage: "pencil")
                            }
                        }
                    
                    Text(source.sourceGroup?.primitiveName ?? "")
                }
            }
        }
    }
}

#Preview {
    CollectionEditSourceListView(sources: []) { _ in
    }
}
