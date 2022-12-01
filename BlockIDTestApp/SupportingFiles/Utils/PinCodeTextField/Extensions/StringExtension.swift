//
//  StringExtension.swift
//  PinCodeTextField
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import UIKit

internal extension String {
    var hasOnlyNewlineSymbols: Bool {
        return trimmingCharacters(in: CharacterSet.newlines).isEmpty
    }
}

internal extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}

// MARK: - Localization -
extension String {
    func localizedMessage(_ code: Int) -> String {
        return String(format: NSLocalizedString(self, comment: ""), code)
    }
    
    func localizedMessage() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func isValidDate(dateFormat: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if dateFormatter.date(from: self) != nil {
            //date parsing succeeded
            return true
        } else {
            // Invalid date
            return false
        }
    }
    
    func toDateFormatted(with string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yy"
        return formatter.date(from: self)
    }
    
    func toDateFormat(with format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}

extension NSMutableAttributedString {
// Make string (or part of string) as hyperlink...
    func createHyperLink(textToFind: String, linkURL: String) -> NSAttributedString? {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            
            // set link URL
            self.addAttribute(NSAttributedString.Key.link,
                              value: linkURL,
                              range: foundRange)
            
            // set underline
            self.addAttribute(NSAttributedString.Key.underlineStyle,
                              value: NSUnderlineStyle.single.rawValue,
                              range: foundRange)
            
            // set line spacing
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 7.0
            self.addAttribute(NSAttributedString.Key.paragraphStyle,
                              value: style,
                              range: NSRange(location: 0, length: self.length))
            
            // set font color
            self.addAttribute(NSAttributedString.Key.foregroundColor,
                              value: UIColor.black,
                              range: NSRange(location: 0, length: self.length))
            
            return self
        }
        
        return nil
    }
}
