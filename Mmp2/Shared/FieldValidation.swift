//
//  FieldValidation.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/29/26.
//

import Foundation

enum FieldValidation<T> {
    case success(T)
    case failure(String)
}
