//
//  StringValidation.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 06/01/22.
//

import Foundation

enum RegexType {
    case SSN
    
    func getRegex() -> String {
        switch self {
        case .SSN:
            return "^[0-9]{9}$"
        }
    }
}

extension String {
    func isValid(type: RegexType) -> Bool {
        let regex = type.getRegex()
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}

