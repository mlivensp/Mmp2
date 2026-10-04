//
//  ErrorFieldModifier.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/28/26.
//

import Foundation
import SwiftUI

struct ErrorFieldModifier: ViewModifier {
    let hasError: Bool

    func body(content: Content) -> some View {
        content
//            .padding(6)
//            .overlay(
//                RoundedRectangle(cornerRadius: 6)
//                    .stroke(hasError ? Color.red : Color.clear, lineWidth: 1)
//            )
    }
}

extension View {
    func errorField(_ hasError: Bool) -> some View {
        self.modifier(ErrorFieldModifier(hasError: hasError))
    }
}
