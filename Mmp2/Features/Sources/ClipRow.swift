//
//  ClipRow.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/15/26.
//

import SwiftUI

struct ClipRow: View {
    let clip: Clip

    var body: some View {
        Label(clip.primitiveName, systemImage: "music.note")
    }
}

//#Preview {
//    ClipRow()
//}
