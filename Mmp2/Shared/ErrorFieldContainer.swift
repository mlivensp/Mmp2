//
//  ErrorFieldContainer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/28/26.
//

import Foundation
import SwiftUI

struct ErrorFieldContainer<Content: View>: View {
    let hasError: Bool
    let errorMessage: String?
    let content: Content

    init(hasError: Bool, errorMessage: String?, @ViewBuilder content: () -> Content) {
        self.hasError = hasError
        self.errorMessage = errorMessage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
                .errorField(hasError)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}
