//
//  View+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/27/26.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func hoverGlow(_ active: Bool) -> some View {
        self.background(
            active
            ? Color.secondary.opacity(0.12)
            : Color.clear
        )
    }
}
