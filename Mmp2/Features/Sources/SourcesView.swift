//
//  SourcesView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import SwiftUI

struct SourcesView: View {
    @Environment(AppRootManager.self) private var appRootManager

    // Convenience
    private var collection: MediaCollection? {
        appRootManager.selectedMediaCollection
    }

    var body: some View {
        Group {
            if let collection {
                SourcesList(collection: collection)
            } else {
                ContentUnavailableView("No Collection Selected", systemImage: "folder")
            }
        }
    }
}

#Preview {
    SourcesView()
}
