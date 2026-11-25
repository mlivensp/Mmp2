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
    @State private var isDeletingCollection: Bool = false
    
    var body: some View {
        let selection = Binding<MediaCollection?>(
            get: { appRootManager.selectedMediaCollection },
            set: { appRootManager.selectCollection($0) }
        )
        
        VStack {
            HStack {
                Text("Collections")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, formPadding)
                Spacer()
                Button {
                    let mediaCollection = MediaCollection.makeDraft();
                    appRootManager.editCollection(mediaCollection)
                } label: {
                    Image(systemName: "plus")
                }
                .padding(.trailing, 4)
            }
            
            Divider()
            
            List(selection: selection) {
                ForEach(mediaCollections) { mediaCollection in
                    NavigationLink(value: mediaCollection) {
                        Text(mediaCollection.primitiveName)
                            .backgroundStyle(.green)
                            .contextMenu {
                                Button {
                                    appRootManager.editCollection(mediaCollection)
                                } label: {
                                    Label("Edit Collection", systemImage: "pencil")
                                }
                                Button {
                                    appRootManager.selectedMediaCollection = mediaCollection
                                    isDeletingCollection = true
                                } label: {
                                    Label("Delete Collection", systemImage: "trash")
                                }
                            }
                    }
                }
                .onDelete(perform: deleteItems)
                .alert(
                    "Delete Collection",
                    isPresented: $isDeletingCollection) {
                        Button("Delete", role: .destructive) {
                            if let mediaCollection = selection.wrappedValue {
                                modelContext.delete(mediaCollection)
                                appRootManager.selectedMediaCollection = nil
                            }
                        }
                        
                        Button("Cancel", role: .cancel) {
                        }
                    } message: {
                        if let mediaCollection = selection.wrappedValue {
                            Text(
                                "Delete \(mediaCollection.primitiveName)? This cannot be undone."
                            )
                        }
                    }
            }
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
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
