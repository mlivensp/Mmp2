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
    
    @State private var isImporting: Bool = false
    
    var body: some View {
        @Bindable var appRootManager = appRootManager
        
        List(selection: $appRootManager.selectedMediaCollection) {
            ForEach(mediaCollections) { mediaCollection in
                NavigationLink(value: mediaCollection) {
                    Text(mediaCollection.primitiveName)
                }
            }
            .onDelete(perform: deleteItems)
        }
        .onChange(of: appRootManager.selectedCategory) { _, newValue in
            if newValue != "Collections" {
                appRootManager.selectedMediaCollection = nil
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
                Button(action: importData) {
                    Label("Import", systemImage: "square.and.arrow.down")
                }
            }
            
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                let importer = Importer()
                importer.importFromURL(url, modelContext: modelContext)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        //        }
    }
    
    private func importData() {
        isImporting = true
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
