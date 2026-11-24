//
//  SourceNameBuilder.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/23/26.
//

import Foundation

enum SourceNameBuilder {
    static func createSourceName(from path: String) -> String {
        let filename = URL(fileURLWithPath: path)
            .deletingPathExtension()
            .lastPathComponent
        let name: String
        
        if let dash = filename.firstIndex(of: "-") {
            name = String(filename[filename.index(after: dash)...])
        } else {
            name = filename
        }
        
        return humanize(name)
    }
    
    private static func humanize(_ text: String) -> String {
        var result = String()
        var previous: Character?
        
        for current in text {
            if current == "-" {
                if result.last != " " {
                    result.append(" ")
                }
                previous = " "
                continue
            }
            
            if let previous {
                let shouldInsertSpace =
                    (previous.isLowercase && current.isUppercase) ||
                    (previous.isLetter && current.isNumber) ||
                    (previous.isNumber && current.isLetter)
                if shouldInsertSpace && result.last != " " {
                    result.append(" ")
                }
            }
            result.append(current)
            previous = current
        }
        
        return result
            .replacingOccurrences(
                of: #"\s+"#,
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
