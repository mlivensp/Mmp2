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
        @Bindable var appRootManager = appRootManager
        
        VStack {
            List(selection: $appRootManager.selectedMediaCollection) {
                ForEach(mediaCollections) { mediaCollection in
                    NavigationLink(value: mediaCollection) {
                        Text(mediaCollection.primitiveName)
                    }
                }
                .onDelete(perform: deleteItems)
            }
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
                Button(action: locateSourcesRequested) {
                    Label("Locate Sources", systemImage: "folder.badge.gearshape")
                }
            }
            ToolbarItem {
                Button(action: importDataRequested) {
                    Label("Import", systemImage: "square.and.arrow.down")
                }
            }
            
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            
        }
        .fileImporter(
            isPresented: $isPresentingFileImporter,
            allowedContentTypes:
                determineAllowedContentTypes(importing: isImporting, locatingSource: isLocatingSource),
            allowsMultipleSelection: false) { result in
                switch result {
                case .success(let url):
                    guard let url = url.first else { return }
                    if isImporting {
                        importData(url: url)
                    } else if isLocatingSource {
                        locateSources(url: url)
                    }
                case .failure(let error):
                    // TODO: handle error
                    print(error.localizedDescription)
                }
        }
//        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
//            switch result {
//            case .success(let url):
//                let importer = Importer()
//                importer.importFromURL(url, modelContext: modelContext)
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//        .fileImporter(
//            isPresented: $isLocatingSource,
//            allowedContentTypes: [.folder],  // This restricts the picker to folders only.
//            allowsMultipleSelection: false
//        ) { result in
//            do {
//                if let url = try result.get().first {
//                    // If you need persistent access to the directory, consider starting a security-scoped session:
//                    // _ = url.startAccessingSecurityScopedResource()
////                    selectedDirectory = url
////                    viewModel.scanDirectory(at: url)
//                }
//            } catch {
//                // Handle any errors here.
//                print("Error selecting directory: \(error.localizedDescription)")
//            }
//        }
    }
    
    private func locateSourcesRequested() {
        isPresentingFileImporter = true
        isLocatingSource = true
        isImporting = false
    }
    
    private func importDataRequested() {
        isPresentingFileImporter = true
        isLocatingSource = true
        isImporting = true
    }
    
    private func determineAllowedContentTypes(importing: Bool, locatingSource: Bool) -> [UTType] {
        if importing {
            return [.json]
        } else if locatingSource {
            return [.folder]
        } else {
            return []
        }
    }
    
    private func importData(url: URL) {
        let importer = Importer()
        importer.importFromURL(url, modelContext: modelContext)
    }
    
    private func locateSources(url: URL) {
        do {
            // If you need persistent access to the directory, consider starting a security-scoped session:
            // _ = url.startAccessingSecurityScopedResource()
//            selectedDirectory = url
//            viewModel.scanDirectory(at: url)
        } catch {
            // Handle any errors here.
            print("Error selecting directory: \(error.localizedDescription)")
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
