//
//  String+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import Foundation

extension String {
    public var normalizedForSearch: String {
        let transformed = applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower; [:^Letter:] Remove"), reverse: false)
        return transformed as String? ?? ""
    }

    public var durationAsSeconds: Double {
        let components = self.split(separator: ":").compactMap { Double($0) }
        guard components.count == 3 else { return 0.0 }
        return (components[0] * 3600.0) + (components[1] * 60.0) + components[2]
    }
}
