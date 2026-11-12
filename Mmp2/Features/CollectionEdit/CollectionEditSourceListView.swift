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
    let onEdit: (Source) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                
                Text("Sources")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
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

                Button {
                    let sortOrder =
                    (vm.mediaCollection.sources.map(\.sortOrder).max() ?? 0) + 1
                    
                    let newSource =
                    Source.makeDraft(sortOrder: sortOrder, mediaCollection: vm.mediaCollection)
                    
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
