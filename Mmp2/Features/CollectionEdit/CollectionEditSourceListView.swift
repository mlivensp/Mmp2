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
            
            HStack {
                
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
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text("Sources")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    let sortOrder =
                    (vm.collection.sources.map(\.sortOrder).max() ?? 0) + 1
                    
                    let newSource =
                    Source.makeDraft(sortOrder: sortOrder)
                    
                    onEdit(newSource)
                } label: {
                    Label(
                        "Add Source",
                        systemImage: "plus"
                    )
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    
                    ForEach(vm.topLevelRows) { row in
                        VStack(alignment: .leading, spacing: 4) {
                            
//                            ForEach(vm.topLevelRows) { row in
                                switch row {
                                    
                                case .group(let group):
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        
                                        HStack {
                                            Text("\(group.sortOrder)")
                                                .padding(.trailing, 4)
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
                                        }
                                        
                                        ForEach(
                                            group.sources.sorted {
                                                $0.sortOrder < $1.sortOrder
                                            }
                                        ) { source in
                                            HStack {
                                                Text("\(source.sortOrder)")
                                                    .padding(.trailing, 4)
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
                                    }
                                    
                                case .ungroupedSource(let source):
                                    HStack {
                                        Text("\(source.sortOrder)")
                                            .padding(.trailing, 4)
                                        Text(source.primitiveName)
                                            .padding(.leading, 4)
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
                                    }
                                    
                                case .groupedSource:
                                    EmptyView()
                                }
                            }
//                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
