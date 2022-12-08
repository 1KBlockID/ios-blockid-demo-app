//
//  AuthQRUWL2.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 26/04/22.
//

import Foundation

public class AuthenticationPayloadV2: NSObject, Codable {
    public var scopes: String?
    public var authtype: String?
    public var strId: String?
    public var sessionId: String?
    public var origin: Origin?
    public var publicKey: String?
    public var createdTS: Int?
    public var expiryTS: Int?
    public var expiresDate: String?
    public var version: Int?
    var metadata: [String: Any]? = [:]

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
        case metadata
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if values.contains(.scopes) {
            scopes = try values.decode(String.self, forKey: .scopes)
        } else {
            scopes = ""
        }
        
        if values.contains(.authtype) {
            authtype = try values.decode(String.self, forKey: .authtype)
        } else {
            authtype = ""
        }
        
        if values.contains(.strId) {
            strId = try values.decode(String.self, forKey: .strId)
        } else {
            strId = ""
        }
        
        if values.contains(.sessionId) {
            sessionId = try values.decode(String.self, forKey: .sessionId)
        } else {
            sessionId = ""
        }
        
        if values.contains(.origin) {
            origin = try values.decode(Origin.self, forKey: .origin)
        } else {
            origin = Origin()
        }
        
        if values.contains(.publicKey) {
            publicKey = try values.decode(String.self, forKey: .publicKey)
        } else {
            publicKey = ""
        }
        
        if values.contains(.createdTS) {
            createdTS = try values.decode(Int.self, forKey: .createdTS)
        } else {
            createdTS = 0
        }
        
        if values.contains(.expiryTS) {
            expiryTS = try values.decode(Int.self, forKey: .expiryTS)
        } else {
            expiryTS = 0
        }
        
        if values.contains(.expiresDate) {
            expiresDate = try values.decode(String.self, forKey: .expiresDate)
        } else {
            expiresDate = ""
        }
        
        if values.contains(.version) {
            version = try values.decode(Int.self, forKey: .version)
        } else {
            version = 0
        }
        
        if values.contains(.metadata) {
            metadata = try values.decode([String: Any].self, forKey: .metadata)
        } else {
            metadata = [String: Any]()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !(scopes?.isEmpty ?? true) {
            try container.encode(self.scopes, forKey: .scopes)
        }
        
        if !(authtype?.isEmpty ?? true) {
            try container.encode(self.authtype, forKey: .authtype)
        }
        
        if !(strId?.isEmpty ?? true) {
            try container.encode(self.strId, forKey: .strId)
        }
        
        if !(sessionId?.isEmpty ?? true) {
            try container.encode(self.sessionId, forKey: .sessionId)
        }
        
        if !(origin == nil) {
            try container.encode(self.origin, forKey: .origin)
        }
        
        if !(publicKey?.isEmpty ?? true) {
            try container.encode(self.publicKey, forKey: .publicKey)
        }
        
        if !(createdTS == nil) {
            try container.encode(self.createdTS, forKey: .createdTS)
        }
        
        if !(expiryTS == nil) {
            try container.encode(self.expiryTS, forKey: .expiryTS)
        }
        
        if !(expiresDate?.isEmpty ?? true) {
            try container.encode(self.expiresDate, forKey: .expiresDate)
        }
        
        if !(version == nil) {
            try container.encode(self.version, forKey: .version)
        }
        
        if !(metadata == nil) {
            try container.encode(self.metadata, forKey: .metadata)
        }
    }

    
    func getAuthRequestModel(sessionUrl: String) -> AuthenticationPayloadV1 {
        let authRequestModel = AuthenticationPayloadV1()
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
