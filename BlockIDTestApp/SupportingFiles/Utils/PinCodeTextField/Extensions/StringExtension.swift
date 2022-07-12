//
//  StringExtension.swift
//  PinCodeTextField
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation

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

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil,
                                 bundle: Bundle.main,
                                 value: "", comment: "")
    }
    
    func localizedMessage(_ code: Int) -> String {
        return self.localized + " (\(code))."
    }
}
