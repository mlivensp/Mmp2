//
//  ClipEditView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/2/26.
//

import SwiftData
import SwiftUI

struct ClipEditView: View {
    @Environment(\.modelContext) private var context
    
    let clip: Clip
    let source: Source
    
   var body: some View {
       ClipEditForm(clip: clip, source: source, context: context)
    }
}

//#Preview {
//    ClipEditView()
//}
