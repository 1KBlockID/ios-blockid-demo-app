//
//  StringValidation.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 06/01/22.
//

import Foundation

enum RegexType {
    case email
    case firstName
    case middleName
    case lastName
    case phone
    case zipCode
    case DOB
    case SSN
    //case address
    
    func getRegex() -> String {
        switch self {
        case .firstName, .middleName, .lastName:
            return "[a-zA-Z ]+"
        case .email:
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        case .phone :
            return "^[0-9]{10}$"
        case .zipCode:
            return "[0-9]{6}"
        case .DOB:
            return "[\\d]{2}(/|-|.)[\\d]{2}(/|-|.)[\\d]{4}"
        case .SSN:
            return "^[0-9]{9}$"
//        case .address:
//            return "^[#.0-9a-zA-Z\s,-]+$"
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

