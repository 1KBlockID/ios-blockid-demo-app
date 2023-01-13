//
//  AuthenticationPayloadV1.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 26/04/22.
//

import Foundation
import BlockIDSDK

public class AuthenticationPayloadV1: NSObject, Codable {
    public var authtype: String? = ""
    public var scopes: String? = ""
    public var creds: String? = ""
    public var publicKey: String? = ""
    public var session: String? = ""
    public var api: String? = ""
    public var tag: String? = ""
    public var community: String? = ""
    public var authPage: String? = ""
    public var name: String? = ""
    var sessionUrl: String? = ""
    public var metadata: [String: Any]? = [:]

    override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case authtype
        case scopes
        case creds
        case publicKey
        case session
        case api
        case tag
        case community
        case authPage
        case name
        case sessionUrl
        case metadata
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if values.contains(.authtype) {
            authtype = try values.decode(String.self, forKey: .authtype)
        } else {
            authtype = ""
        }
        
        if values.contains(.scopes) {
            scopes = try values.decode(String.self, forKey: .scopes)
        } else {
            scopes = ""
        }
        
        if values.contains(.creds) {
            creds = try values.decode(String.self, forKey: .creds)
        } else {
            creds = ""
        }
        
        if values.contains(.publicKey) {
            publicKey = try values.decode(String.self, forKey: .publicKey)
        } else {
            publicKey = ""
        }
        
        if values.contains(.session) {
            session = try values.decode(String.self, forKey: .session)
        } else {
            session = ""
        }
        
        if values.contains(.api) {
            api = try values.decode(String.self, forKey: .api)
        } else {
            api = ""
        }
        
        if values.contains(.tag) {
            tag = try values.decode(String.self, forKey: .tag)
        } else {
            tag = ""
        }
        
        if values.contains(.community) {
            community = try values.decode(String.self, forKey: .community)
        } else {
            community = ""
        }
        
        if values.contains(.authPage) {
            authPage = try values.decode(String.self, forKey: .authPage)
        } else {
            authPage = ""
        }
        
        if values.contains(.name) {
            name = try values.decode(String.self, forKey: .name)
        } else {
            name = ""
        }
        
        if values.contains(.sessionUrl) {
            sessionUrl = try values.decode(String.self, forKey: .sessionUrl)
        } else {
            sessionUrl = ""
        }
        
        if values.contains(.metadata) {
            metadata = try values.decode([String: Any].self, forKey: .metadata)
        }
        else {
            metadata = [String: Any]()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !(authtype?.isEmpty ?? true) {
            try container.encode(self.authtype, forKey: .authtype)
        }
        
        if !(scopes?.isEmpty ?? true) {
            try container.encode(self.scopes, forKey: .scopes)
        }
        
        if !(creds?.isEmpty ?? true) {
            try container.encode(self.creds, forKey: .creds)
        }
        
        if !(publicKey?.isEmpty ?? true) {
            try container.encode(self.publicKey, forKey: .publicKey)
        }
        
        if !(session?.isEmpty ?? true) {
            try container.encode(self.session, forKey: .session)
        }
        
        if !(api?.isEmpty ?? true) {
            try container.encode(self.api, forKey: .api)
        }
        
        if !(tag?.isEmpty ?? true) {
            try container.encode(self.tag, forKey: .tag)
        }
        
        if !(community?.isEmpty ?? true) {
            try container.encode(self.community, forKey: .community)
        }
        
        if !(authPage?.isEmpty ?? true) {
            try container.encode(self.authPage, forKey: .authPage)
        }
        
        if !(name?.isEmpty ?? true) {
            try container.encode(self.name, forKey: .name)
        }
        
        if !(sessionUrl?.isEmpty ?? true) {
            try container.encode(self.sessionUrl, forKey: .sessionUrl)
        }
        
        if !(metadata == nil) {
            try container.encode(self.metadata, forKey: .metadata)
        }
    }

    func getBidOrigin() -> BIDOrigin? {
        let bidOrigin = BIDOrigin()
        bidOrigin.api = self.api
        bidOrigin.tag = self.tag
        bidOrigin.name = self.name
        bidOrigin.community = self.community
        bidOrigin.publicKey = self.publicKey
        bidOrigin.session = self.session
        bidOrigin.authPage = self.authPage
        
        if (bidOrigin.authPage == nil) { //default to native auth without a specific method.
            bidOrigin.authPage = AccountAuthConstants.kNativeAuthScehema
        }
        
        return bidOrigin
    }
}
