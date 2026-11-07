//
//  Double+Extensions.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/6/26.
//

import Foundation

extension Double {
    func roundedTo1Place() -> Double {
        (self * 10).rounded() / 10
    }
    func roundedTo2Places() -> Double {
        (self * 100).rounded() / 100
    }
}
