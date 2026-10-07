//
//  SourcesView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import OSLog
import SwiftUI

struct SourcesView: View {
    @Environment(AppRootManager.self) private var appRootManager

    // Convenience
    private var collection: MediaCollection? {
        appRootManager.selectedMediaCollection
    }

    var body: some View {
        SourcesList(
            collection: collection,        // make this parameter optional in SourcesList
            onSourceTapped: { appRootManager.play(source: $0) },
            onClipTapped:   { appRootManager.play(clip: $0) }
        )
        .overlay {
            if collection == nil {
                ContentUnavailableView("No Collection Selected", systemImage: "folder")
            }
        }
    }}

#Preview {
    SourcesView()
}
