//
//  CollectionEditView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/5/26.
//

import SwiftData
import SwiftUI

struct CollectionEditView: View {
    @Environment(\.modelContext) private var context
    
    @State var collection: MediaCollection
    var body: some View {
        VStack(spacing: 0) {
            Text("Edit Collection")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            CollectionEditForm(collection: collection, context: context)
        }
        .padding(formPadding)
    }
}

//#Preview {
//    CollectionEditView()
//}
