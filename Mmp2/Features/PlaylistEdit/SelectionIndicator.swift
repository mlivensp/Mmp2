//
//  SelectionIndicator.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/9/26.
//

import SwiftUI

struct SelectionIndicator: View {
    let isSelected: Bool
    
    var body: some View {
        Image(
            systemName: isSelected
            ? "checkmark.circle.fill"
            : "circle"
        )
        .foregroundColor(
            isSelected
            ? .accentColor
            : .secondary
        )
    }
}
#Preview {
    SelectionIndicator(isSelected: false)
}
