//
//  UserDefualt+Ext.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
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

