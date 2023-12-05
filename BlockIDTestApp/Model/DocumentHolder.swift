//
//  DocumentHolder.swift
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import BlockID

class DocumentStore : NSObject {
    var documentData: [String : Any]?
    var type: String?
    
    public static let sharedInstance = DocumentStore()
    
    public func hasData() -> Bool {
        return (documentData != nil) ? true : false
    }
    
    public func setData(documentData: [String : Any]?) {
        self.documentData = documentData
        self.type = documentData?["type"] as? String ?? ""
    }
    
    public func clearData() {
        self.documentData = nil
        self.type = nil
    }
    
    public func getDocumentStoreData() -> DocumentStore {
        return self
    }
}
