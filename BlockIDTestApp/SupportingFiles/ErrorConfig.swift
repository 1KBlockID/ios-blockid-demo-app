//
//  ErrorConfig.swift
//  BlockIDTestApp
//
//  Created by vaidehi hindlekar on 05/05/21.
//

import Foundation
enum ErrorConfig {
    case noInternet
    case error
    
    var title: String {
        switch self {
        case .noInternet:
            return "You are offline!"
        case .error:
            return "Error"
        }
    }
    
    var message: String {
        switch self {
        case .noInternet:
            return "Please check your internet connection"
        case .error:
            return "Something went wrong"
        }
    }
    
}
