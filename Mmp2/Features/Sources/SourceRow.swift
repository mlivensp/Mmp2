//
//  SourceRow.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import SwiftUI

struct SourceRow: View {
    let source: Source

    var body: some View {
        Label {
            Text(source.primitiveName)
        } icon: {
            Image(systemName: source.isFavorite ? "star.fill" : "doc")
        }
    }
}

//#Preview {
//    SourceRow()
//}
