//
//  DocumentMapUtil.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import BlockIDSDK

public enum DocumentCategory: String {
    case identity_document = "identity_document"
    case misc_document =  "misc_document"
}
class DocumentMapUtil {
    public static let id = "id"
    public static let type = "type"
    public static let category = "category"
    public static let proofedBy = "proofedBy"
    public static let uuid = "uuid"

    
    public static let K_PROOFEDBY_BLOCK_ID = "blockid";
    
    public static func getDocumentMap(documentData: BIDDocumentData, documentCategory: DocumentCategory)-> [String: Any] {
        let jsonString = CommonFunctions.objectToJSONString(documentData)
        var docMap = CommonFunctions.convertJSONStringToJSONObject(_:jsonString) as! [String : Any]
        docMap["id"] = documentData.id
        docMap["type"] = documentData.type
        docMap["category"] = documentCategory.rawValue
        docMap["proofedBy"] = K_PROOFEDBY_BLOCK_ID
       
        return docMap
    }
}

