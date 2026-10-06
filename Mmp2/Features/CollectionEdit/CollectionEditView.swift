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
        let _ = print("CollectionEditView - \(collection.primitiveName)")
        CollectionEditForm(collection: collection, context: context)
    }
}

//#Preview {
//    CollectionEditView()
//}
