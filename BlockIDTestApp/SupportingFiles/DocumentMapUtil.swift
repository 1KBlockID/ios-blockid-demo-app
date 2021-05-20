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
    private static let id = "id"
    private static let type = "type"
    private static let category = "category"
    private static let proofedBy = "proofedBy"
    private static let uuid = "uuid"

    
    private static let K_PROOFEDBY_BLOCK_ID = "blockid";
    
    public static func getDocumentMap(documentData: BIDDocumentData, documentCategory: DocumentCategory)-> [String: Any] {
        var dlMap = [String: Any]()
        dlMap["id"] = documentData.id
        dlMap["type"] = documentData.type
        dlMap["category"] = documentCategory.rawValue
        dlMap["proofedBy"] = K_PROOFEDBY_BLOCK_ID
        let jsonString = CommonFunctions.objectToJSONString(documentData)
        let jsonObj = CommonFunctions.convertJSONStringToJSONObject(_:jsonString)
        dlMap["uuid"] = jsonObj
        return dlMap
    }
}

