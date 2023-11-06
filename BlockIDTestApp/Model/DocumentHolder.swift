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
    var token : String?
    var type: String?
    
    public static let sharedInstance = DocumentStore()
    
    public func hasData() -> Bool {
        return (documentData != nil) ? true : false
    }
    
    public func setData(documentData: [String : Any]?, token: String?) {
        self.documentData = documentData
        self.token = token
        self.type = documentData?["type"] as? String ?? ""
    }
    
    public func clearData() {
        self.documentData = nil
        self.token = nil
        self.type = nil
    }
    
    public func getDocumentStoreData() -> DocumentStore {
        return self
    }
}
