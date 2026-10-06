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
    
    let collection: MediaCollection
    var body: some View {
        Text("Edit \(collection.primitiveName)")
    }
}

//#Preview {
//    CollectionEditView()
//}
