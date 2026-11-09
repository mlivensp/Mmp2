//
//  PlaylistEditView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/7/26.
//

import SwiftData
import SwiftUI

struct PlaylistEditView: View {
    @Environment(\.modelContext) private var context
    let playlist: Playlist
    
    var body: some View {
        PlaylistEditForm(playlist: playlist, context: context)
    }
}

//#Preview {
//    PlaylistEditView()
//}
