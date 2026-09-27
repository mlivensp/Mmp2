//
//  ClipListRow.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/25/26.
//

import SwiftUI

struct ClipListRow: View {
    let clip: Clip
    
    var body: some View {
        Text(clip.primitiveName)
    }
}

//#Preview {
//    ClipListRow()
//}
