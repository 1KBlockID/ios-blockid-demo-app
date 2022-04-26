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
