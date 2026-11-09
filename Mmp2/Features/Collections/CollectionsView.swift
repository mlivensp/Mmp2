//
//  CollectionsView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import SwiftData
import SwiftUI
internal import UniformTypeIdentifiers

struct CollectionsView: View {
    @Environment(AppRootManager.self) var appRootManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MediaCollection.name_normalized) private var mediaCollections: [MediaCollection]
    
    @State private var isPresentingFileImporter: Bool = false
    @State private var isImporting: Bool = false
    @State private var isLocatingSource: Bool = false
    
    var body: some View {
        let selection = Binding<MediaCollection?>(
            get: { appRootManager.selectedMediaCollection },
            set: { appRootManager.selectCollection($0) }
        )

        VStack {
            List(selection: selection) {
                ForEach(mediaCollections) { mediaCollection in
                    NavigationLink(value: mediaCollection) {
                        Text(mediaCollection.primitiveName)
                            .contextMenu {
                                Button {
                                    appRootManager.editCollection(mediaCollection)
                                } label: {
                                    Label("Edit Collection", systemImage: "pencil")
                                }
                            }
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
            
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            
        }
    }
    
    private func addItem() {
        //        withAnimation {
        //            let newItem = CatalogCollection(timestamp: Date())
        //            modelContext.insert(newItem)
        //        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        //        withAnimation {
        //            for index in offsets {
        //                modelContext.delete(items[index])
        //            }
        //        }
    }
}

fileprivate struct NavigationViewWrapper<Content: View>: View {
    let content: () -> Content
    
    var body: some View {
#if os(macOS)
        NavigationSplitView {
            content()
        } detail: {
            Text("Select an item")
        }
#else
        content()
#endif
    }
}

#Preview {
    CollectionsView()
}
