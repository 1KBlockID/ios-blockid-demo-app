//
//  DocumentHolder.swift
//  BlockIDTestApp
//
//  Created by vaidehi hindlekar on 11/05/21.
//

import Foundation
import BlockIDSDK

class DocumentStore : NSObject {
    var docType : BIDDocumentType?
    var documentData: BIDDocumentData?
    var token : String?
    
    public static let sharedInstance = DocumentStore()
    
    public func hasData() -> Bool {
        return (documentData != nil) ? true : false
    }
    
    public func setData(docType: BIDDocumentType, documentData: BIDDocumentData, token: String) {
        self.docType = docType
        self.documentData = documentData
        self.token = token
    }
    
    public func clearData() {
        self.docType = nil
        self.documentData = nil
        self.token = nil
    }
    
    public func getDocumentStoreData() -> DocumentStore {
        return self
    }
}
