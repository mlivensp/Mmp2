//
//  LastPlayedView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/17/26.
//

import OSLog
import SwiftData
import SwiftUI

struct RecentsView: View {
    @Environment(AppRootManager.self) var appRootManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var selection: PersistentIdentifier?
    
    var body: some View {
        VStack {
            Text("Recents")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            let recentItems = fetchLastPlayed()
            List(selection: $selection) {
                ForEach(recentItems) { item in
                    HStack(spacing: 8) {
                        if item.isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                                .frame(width: 20)
                        } else {
                            Color.clear
                                .frame(width: 20, height: 1)
                        }
                        
                        Text(item.name)
                            .padding(.trailing, 8)
                            .frame(width: 500, alignment: .leading)
                        Spacer()
                        Text(item.lastPlayed, format: .dateTime)
                    }
                    .tag(item.id)
                    .onTapGesture {
                        switch item.reference {
                        case .source(let source):
                            appRootManager.play(source: source)
                        case .clip(let clip):
                            appRootManager.play(clip: clip)
                        }
                    }
                }
            }
        }
        .padding(formPadding)
    }
    
    private func fetchLastPlayed() -> [RecentItem] {
        let sourceFetchDescriptor = FetchDescriptor<Source>(
            predicate: #Predicate<Source> {
                $0.lastPlayed != nil
            }
        )
        
        let clipFetchDescriptor = FetchDescriptor<Clip>(
            predicate: #Predicate<Clip> {
                $0.lastPlayed != nil
            }
        )
        
        do {
            let sources = try modelContext.fetch(sourceFetchDescriptor)
            let clips = try modelContext.fetch(clipFetchDescriptor)
            let recents: [RecentItem] =
            (sources.map {
                let reference: PlayableReference = .source($0)
                return RecentItem(
                    reference: reference,
                    name: $0.name,
                    lastPlayed: $0.lastPlayed!,
                    isFavorite: $0.isFavorite
                )
            } +
             clips.map {
                let reference: PlayableReference = .clip($0)
                return RecentItem(
                    reference: reference,
                    name: $0.name,
                    lastPlayed: $0.lastPlayed!,
                    isFavorite: $0.isFavorite
                )
            })
            .sorted { $1.lastPlayed < $0.lastPlayed }
            
            // TODO: make number of recents configurable
            return Array(recents.prefix(25))
        } catch {
            Logger.data.error("Fetching LastPlayed: \(error.localizedDescription)")
            return []
        }
    }
}

//#Preview {
//    RecentsView()
//}
