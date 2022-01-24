//
//  DictionaryExtension.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 21/01/22.
//

import Foundation

extension Dictionary {
    func search(key: String, in dict:[String:Any] = [:]) -> Any? {
        guard var currDict = self as? [String : Any]  else { return nil }
        currDict = !dict.isEmpty ? dict : currDict

        if let foundValue = currDict[key] {
            return foundValue
        } else {
            for val in currDict.values {
                if let innerDict = val as? [String:Any], let result = search(key: key, in: innerDict) {
                    return result
                }
            }
            return nil
        }
    }
}
