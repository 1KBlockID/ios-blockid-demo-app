//
//  AuthQRUWL2.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 26/04/22.
//

import Foundation

public class AuthQRUWL2: NSObject, Codable {
    public var scopes: String? = ""
    public var authtype: String? = ""
    public var strId: String? = ""
    public var sessionId: String? = ""
    public var origin: Origin?
    public var publicKey: String? = ""
    public var createdTS: Int?
    public var expiryTS: Int?
    public var expiresDate: String? = ""
    public var version: Int?
    
    enum CodingKeys: String, CodingKey {
        case scopes
        case authtype
        case strId = "_id"
        case sessionId
        case origin
        case publicKey
        case createdTS
        case expiryTS
        case expiresDate
        case version = "__v"
    }
    
    func getAuthRequestModel(sessionUrl: String) -> AuthQRModel {
        let authRequestModel = AuthQRModel()
        authRequestModel.authtype = self.authtype
        authRequestModel.scopes = self.scopes
        authRequestModel.creds = ""
        authRequestModel.publicKey = self.publicKey
        authRequestModel.session = self.sessionId
        authRequestModel.api = self.origin?.url
        authRequestModel.tag = self.origin?.tag
        authRequestModel.community = self.origin?.communityName
        authRequestModel.authPage = self.origin?.authPage
        authRequestModel.sessionUrl = sessionUrl
        
        return authRequestModel
    }
}

public class Origin: Codable {
    public var tag: String? = ""
    public var url: String? = ""
    public var communityName: String? = ""
    public var communityId: String? = ""
    public var authPage: String? = ""
}
