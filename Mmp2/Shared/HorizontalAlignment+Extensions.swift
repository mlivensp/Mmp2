//
//  HorizontalAlignment+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/6/26.
//

import Foundation
import SwiftUI

extension HorizontalAlignment {
    private enum SourceNameColumn: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[.leading]
        }
    }

    static let sourceNameColumn = HorizontalAlignment(SourceNameColumn.self)
}
