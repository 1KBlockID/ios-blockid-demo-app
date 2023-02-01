//
//  AuthLinkURLData.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 11/05/22.
//

import Foundation
import BlockID

public class AuthLinkUrlData: Codable {

    var data: String!
    private var publicKey: String!
    private var publickey: String!
    
    public func getPublicKey() -> String {
        return publickey != nil ? publickey : publicKey
    }
    
    public func authUserData() -> AuthenticateUserData? {
        guard let data = data, let decryptedStr = BlockIDSDK.sharedInstance.decryptString(str: data, senderKey: getPublicKey()) else {
            return nil
        }
        let authUserData = CommonFunctions.jsonStringToObject(json: decryptedStr) as AuthenticateUserData?
        return authUserData
    }
 
}

public class AuthenticateUserData: Codable {

    var userId: String!
    var account: BIDAccount?
}
