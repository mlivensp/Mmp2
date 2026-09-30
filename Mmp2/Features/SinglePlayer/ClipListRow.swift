//
//  ClipListRow.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/25/26.
//

import SwiftUI

struct ClipListRow: View {
    let clip: Clip
    @State private var isHovering = false

    var body: some View {
        HStack {
            Text(clip.primitiveName)
                .foregroundColor(isHovering ? .secondary : .primary)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .hoverGlow(isHovering)
//        .background(
//            isHovering
//            ? Color.secondary.opacity(0.12)
//            : Color.clear
//        )
        .animation(.easeInOut(duration: 0.12), value: isHovering)
        .onHover { inside in
            isHovering = inside
        }
    }
}

//#Preview {
//    ClipListRow()
//}
