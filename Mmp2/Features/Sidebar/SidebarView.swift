//
//  SidebarView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import SwiftUI

struct SidebarView: View {
    @Environment(AppRootManager.self) var appRootManager
    
    init() {
    }

    var body: some View {
        @Bindable var appRootManager = appRootManager
        
        List(selection: $appRootManager.selectedCategory) {
            ForEach(AppRootManager.AppCategory.allCases) { category in
                NavigationLink(value: category) {
                    Text(category.rawValue)
                }
            }
        }
    }
}

#Preview {
    SidebarView()
}
