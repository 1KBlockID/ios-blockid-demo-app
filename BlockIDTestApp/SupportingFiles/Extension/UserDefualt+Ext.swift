//
//  UserDefualt+Ext.swift
//  BlockIDTestApp
//
//  Created by vaidehi hindlekar on 04/05/21.
//

import Foundation

extension UserDefaults {
    
    static func contains(_ key: String) -> Bool {
        return self.standard.object(forKey: key) != nil
    }
        
    static func removeAllValues() {
        let dictionary = self.standard.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            self.standard.removeObject(forKey:key)
        }
    }
    
}

