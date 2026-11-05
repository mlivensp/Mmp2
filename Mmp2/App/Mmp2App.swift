//
//  Mmp2App.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import OSLog
import SwiftUI
import SwiftData
internal import UniformTypeIdentifiers

@main
struct Mmp2App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = SchemaV1.schema
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var appRootManager = AppRootManager.shared
    @Environment(\.scenePhase) var scenePhase
    
    @State private var isWorking: Bool = false
    @State private var progress: Double = 0
    @State private var repairTask: Task<Void, Never>? = nil

    
    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(appRootManager: appRootManager)
                .fileImporter(
                    isPresented: $appRootManager.showImportCatalog,
                    allowedContentTypes: [.json],
                    allowsMultipleSelection: false) { result in
                        switch result {
                        case .success(let url):
                            guard let url = url.first else { return }
                            do {
                                let importer = Importer()
                                try importer.importFromURL(url, modelContext: sharedModelContainer.mainContext)
                            } catch {
                                // TODO: notify user
                                let _ = print(error.localizedDescription)
                            }
                        case .failure(let error):
                            // TODO: handle error
                            print(error.localizedDescription)
                        }
                    }
                    .fileImporter(
                        isPresented: $appRootManager.showLocateSources,
                        allowedContentTypes: [.folder],
                        allowsMultipleSelection: false) { result in
                            switch result {
                            case .success(let url):
                                guard let url = url.first else { return }
                                do {
                                    try locateSources(using: url)
                                } catch {
                                    // Handle any errors here.
                                    print("Error selecting directory: \(error.localizedDescription)")
                                }
                            case .failure(let error):
                                // TODO: handle error
                                print(error.localizedDescription)
                            }
                        }
                        .overlay(alignment: .bottom) {
                            if isWorking {
                                VStack(spacing: 12) {
                                    ProgressView(value: progress)
                                        .progressViewStyle(.linear)
                                        .padding(.horizontal)
                                    
                                    Button("Cancel") {
                                        cancelLocateSources()
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                .padding()
                                .background(.thinMaterial)
                                .cornerRadius(12)
                                .padding()
                            }
                        }
        }
        .modelContainer(sharedModelContainer)
        .environment(appRootManager)
        .commands {
            MyCommands(appRootManager: appRootManager)
        }
    }
    
    private func locateSources(using folderURL: URL) throws {
        let fetchDescriptor = FetchDescriptor<Media>(predicate: #Predicate { media in
            media.pathIsValid == false && media.clip == nil
        })
        let items = try sharedModelContainer.mainContext.fetch(fetchDescriptor)
        guard !items.isEmpty else { return }
        
        isWorking = true
        progress = 0
        let locator = SourceLocatorActor(modelContainer: sharedModelContainer)
        
        repairTask = Task {
            do {
                try await locator.repairPaths(
                    in: folderURL,
                    mediaItems: items
                ) { update in
                    // MainActor guaranteed by actor
                    self.progress = Double(update.checked) / Double(update.total)
                }
                
                // Finished
                isWorking = false
                repairTask = nil
                //                loadInvalidPaths()
                
            } catch is CancellationError {
                print("Repair cancelled")
                isWorking = false
                repairTask = nil
                
            } catch {
                print("Repair failed: \(error)")
                isWorking = false
                repairTask = nil
            }
        }
    }
    
    private func cancelLocateSources() {
        repairTask?.cancel()
        repairTask = nil
        isWorking = false
    }
}

struct MyCommands: Commands {
    let appRootManager: AppRootManager
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Import Catalog...") {
                appRootManager.showImportCatalog = true
            }
            Button("Export Catalog...") {
                
            }
        }
        
        CommandGroup(replacing: .saveItem) {
            Button("Locate Source Files...") {
                appRootManager.showLocateSources = true
            }
        }
        
        //        CommandGroup(replacing: .) { }
        //        CommandGroup(replacing: .printItem) { }
        //
        //        CommandMenu("Library") {
        //            Button("Scan Library") {
        //                print("Scan")
        //            }
        //            .keyboardShortcut("s")
        //
        //            Divider()
        //
        //            Button("Refresh Metadata") {
        //                print("Refresh")
        //            }
        //        }
    }
}
