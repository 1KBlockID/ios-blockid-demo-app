//
//  DateExtension.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 13/10/22.
//

import Foundation


extension Date {
    func toStringDate(with format: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
