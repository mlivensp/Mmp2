//
//  SinglePlayerView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/15/26.
//

import SwiftUI

struct SinglePlayerView: View {
    @Environment(AppRootManager.self) private var appRootManager
    
    var body: some View {
        if let source = appRootManager.selectedSource {
            Text("Playing source \(source.primitiveName)")
        } else if let clip = appRootManager.selectedClip {
            Text("Playing clip \(clip.primitiveName)")
        } else {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

#Preview {
    SinglePlayerView()
}
