//
//  FieldValidation.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/29/26.
//

import Foundation

enum ValidationResult<T> {
    case success(T)
    case failure(String)
}
