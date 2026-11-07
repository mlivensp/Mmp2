//
//  CollectionEditSourceListView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/6/26.
//

import SwiftData
import SwiftUI

struct CollectionEditSourceListView: View {
    @Environment(AppRootManager.self) private var appRootManager

    @State private var selectedRow: CollectionRow?
    
    let vm: CollectionEditView.ViewModel
//    let collection: MediaCollection
//    let sources: [Source]
    let onEdit: (Source) -> Void
    
    private var columns: [GridItem] = [
        GridItem(.flexible(), alignment: .leading),  // source name column
        GridItem(.flexible(), alignment: .leading),  // group name column
        GridItem(.flexible(), alignment: .leading),  // sort order
        GridItem(.flexible(), alignment: .leading)   // sort order
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
                    let sortOrder = (vm.collection.sources.map(\.sortOrder).max() ?? 0) + 1
                    let newSource = Source.makeDraft(sortOrder: sortOrder)
                    onEdit(newSource)
                } label: {
                    Label("Add Source", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                Button {
                    if let selectedRow {
                        vm.moveUp(selectedRow)
                    }
                } label: {
                    Image(systemName: "arrow.up")
                }
                .buttonStyle(.bordered)

                Button {
                    if let selectedRow {
                        vm.moveDown(selectedRow)
                    }
                } label: {
                    Image(systemName: "arrow.down")
                }
                .buttonStyle(.bordered)            }
            .padding(.horizontal)
            
            ForEach(vm.topLevelRows) { row in
                switch row {

                case .group(let group):

                    VStack(alignment: .leading, spacing: 4) {

                        Text(group.primitiveName)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(4)
                            .background(
                                selectedRow == .group(group)
                                    ? Color.accentColor.opacity(0.2)
                                    : Color.clear
                            )
                            .onTapGesture {
                                selectedRow = .group(group)
                            }
                        
                        ForEach(
                            group.sources.sorted {
                                $0.sortOrder < $1.sortOrder
                            }
                        ) { source in
                            
                            Text(source.primitiveName)
                                .padding(.leading, 24)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(4)
                                .background(
                                    selectedRow == .groupedSource(source)
                                        ? Color.accentColor.opacity(0.2)
                                        : Color.clear
                                )
                                .onTapGesture {
                                    selectedRow = .groupedSource(source)
                                }
                        }
                    }

                case .ungroupedSource(let source):

                    Text(source.primitiveName)
                        .padding(.leading, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                        .background(
                            selectedRow == .ungroupedSource(source)
                                ? Color.accentColor.opacity(0.2)
                                : Color.clear
                        )
                        .onTapGesture {
                            selectedRow = .ungroupedSource(source)
                        }
                case .groupedSource:
                    EmptyView()
                }
            }
        }
    }    
    
    //    private func groupSortOrder(_ sortOrder: Int?) -> String {
//        guard let sortOrder else { return "" }
//        return "\(sortOrder)"
//    }
}

//#Preview {
//    CollectionEditSourceListView(sources: []) { _ in
//    }
//}
//    private var rows: [CollectionSourceRow] {
//        var rows: [CollectionSourceRow] = []
//
//        let groupedSources = Set(
//            sources.compactMap(\.sourceGroup)
//        )
//
//        for group in groupedSources.sorted(by: {
//            $0.sortOrder < $1.sortOrder
//        }) {
//
//            rows.append(.group(group))
//
//            for source in group.sources.sorted(by: {
//                $0.sortOrder < $1.sortOrder
//            }) {
//                rows.append(.source(source))
//            }
//        }
//
//        let ungroupedSources = sources
//            .filter { $0.sourceGroup == nil }
//            .sorted { $0.sortOrder < $1.sortOrder }
//
//        rows.append(contentsOf:
//            ungroupedSources.map(CollectionSourceRow.source)
//        )
//
//        return rows
//    }
//            LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
//                Text("Name")
//                    .font(.headline)
//                Text("Group")
//                    .font(.headline)
//                Text("Group Sort")
//                    .font(.headline)
//                Text("Sort")
//                    .font(.headline)
//                ForEach(sources) { source in
//                    Text(source.primitiveName)
//                        .contextMenu {
//                            Button {
//                                onEdit(source)
//                            } label: {
//                                Label("Edit Source", systemImage: "pencil")
//                            }
//                        }
//
//                     Text(source.sourceGroup?.primitiveName ?? "")
//                     Text(groupSortOrder(source.sourceGroup?.sortOrder))
//                     Text("\(source.sortOrder)")
//                 }
//             }
