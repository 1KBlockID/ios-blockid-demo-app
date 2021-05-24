//
//  DocumentMapUtil.swift
//  BlockIDTestApp
//
//  Created by vaidehi hindlekar on 19/05/21.
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
        var docMap = [String: Any]()
        docMap["id"] = documentData.id
        docMap["type"] = documentData.type
        docMap["category"] = documentCategory.rawValue
        docMap["proofedBy"] = K_PROOFEDBY_BLOCK_ID
        let jsonString = CommonFunctions.objectToJSONString(documentData)
        let jsonObj = CommonFunctions.convertJSONStringToJSONObject(_:jsonString)
        docMap["uuid"] = jsonObj
        return docMap
    }
}

