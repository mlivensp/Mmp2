//
//  CollectionEditForm.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/6/26.
//

import SwiftData
import SwiftUI

struct CollectionEditForm: View {
    @Environment(AppRootManager.self) private var appRootManager
    
    @State private var vm: CollectionEditView.ViewModel
    
    init(collection: MediaCollection, context: ModelContext) {
        _vm = State(initialValue: CollectionEditView.ViewModel(collection: collection, context: context))
    }

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//#Preview {
//    CollectionEditForm()
//}
