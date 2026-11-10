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
       VStack(spacing: 0) {
           Text("Edit Clip")
               .font(.largeTitle)
               .fontWeight(.semibold)
               .frame(maxWidth: .infinity, alignment: .leading)
           ClipEditForm(clip: clip, source: source, context: context)
       }
       .padding(formPadding)
    }
}

//#Preview {
//    ClipEditView()
//}
