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

}
