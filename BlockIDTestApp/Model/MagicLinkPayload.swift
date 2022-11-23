//
//  MagicLinkPayload.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 11/05/22.
//

import Foundation
import BlockIDSDK

 class MagicLinkPayload: Codable {
    var did: String!
    var sender: String!
    var code: String!
    var os: String!
    var ial: String!
    var eventData: String!
    var phoneNumber: String?
    
    init(did: String, eventData: String, sender: String, code: String, os: String!, ial: String!) {
        self.did = did
        self.sender = sender
        self.code = code
        self.os = os
        self.ial = ial
        self.eventData = eventData
    }
    
    func encryptedData(_ publicKey: String) -> String? {
        return BlockIDSDK.sharedInstance.encryptString(str: CommonFunctions.objectToJSONString(self), rcptKey: publicKey)
    }
}

 class RequestUrlPayload: Codable {
    var data: String!
    var publicKey: String!
    
    init(data: MagicLinkPayload, publicKey: String) {
        self.data = data.encryptedData(publicKey)
        self.publicKey = BlockIDSDK.sharedInstance.getWalletPublicKey()
    }
    
    func base64Payload() -> String {
        let payloadData = CommonFunctions.objectToJSONString(self).data(using: .utf8)
        return (payloadData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)))!
    }
}
