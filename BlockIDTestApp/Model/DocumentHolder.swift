//
//  DocumentHolder.swift
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import BlockIDSDK

class DocumentStore : NSObject {
    var docType : BIDDocumentType?
    var documentData: [String : Any]?
    var token : String?
    var type: String?
    
    public static let sharedInstance = DocumentStore()
    
    public func hasData() -> Bool {
        return (documentData != nil) ? true : false
    }
    
    public func setData(docType: BIDDocumentType, documentData: [String : Any]?, token: String) {
        self.docType = docType
        self.documentData = documentData
        self.token = token
        self.type = documentData?["type"] as? String ?? ""
    }
    
    public func clearData() {
        self.docType = nil
        self.documentData = nil
        self.token = nil
        self.type = nil
    }
    
    public func getDocumentStoreData() -> DocumentStore {
        return self
    }
}
