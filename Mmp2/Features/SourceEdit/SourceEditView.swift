//
//  SourceEditView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/5/26.
//

import SwiftData
import SwiftUI

struct SourceEditView: View {
    @Environment(\.modelContext) private var context
    
    let source: Source
    let collection: MediaCollection
    
    var body: some View {
        SourceEditForm(source: source, collection: collection, context: context)
            .navigationTitle("Edit Source")
    }
}

//#Preview {
//    SourceEditView()
//}
