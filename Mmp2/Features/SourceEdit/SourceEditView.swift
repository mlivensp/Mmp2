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
        VStack(spacing: 0) {
            Text("Edit Source")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            SourceEditForm(source: source, collection: collection, context: context)
                .navigationTitle("Edit Source")
        }
        .padding(formPadding)
    }
}

//#Preview {
//    SourceEditView()
//}
