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
    
    @State fileprivate var selectedRow: CollectionRow?
    
    let vm: CollectionEditView.ViewModel
    let onEdit: (Source) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sources")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            
            Divider()
            
            HStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        
                        ForEach(vm.topLevelRows) { row in
                            VStack(alignment: .leading, spacing: 4) {
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Divider()
                
                toolbar
                    .frame(width: 30)
            }
        }
    }
}

private extension CollectionEditSourceListView {

    var toolbar: some View {

        VStack(spacing: 8) {

            Button {
                let sortOrder =
                (vm.mediaCollection.sources.map(\.sortOrder).max() ?? 0) + 1
                
                let newSource =
                Source.makeDraft(sortOrder: sortOrder, mediaCollection: vm.mediaCollection)
                
                onEdit(newSource)
            } label: {
                Label("Add", systemImage: "plus")
            }

            Button {
                guard let row = selectedRow else {
                    return
                }

                self.selectedRow = vm.delete(row: row)

            } label: {
                Label("Delete", systemImage: "trash")
            }
            .disabled(selectedRow == nil)

            Divider()

            Button {
                guard let row = selectedRow else {
                    return
                }

                vm.moveUp(row)

            } label: {
                Image(systemName: "arrow.up")
            }
            .disabled(
                selectedRow == nil ||
                selectedRow == vm.topLevelRows.first
            )

            Button {
                guard let row = selectedRow else {
                    return
                }

                vm.moveDown(row)

            } label: {
                Image(systemName: "arrow.down")
            }
            .disabled(
                selectedRow == nil ||
                selectedRow == vm.topLevelRows.last
            )

            Spacer()
        }
        .padding()
    }
}
