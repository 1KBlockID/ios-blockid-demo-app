//
//  MagicLinkModel.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 10/05/22.
//

import Foundation
import BlockIDSDK

class MagicLinkModel: NSObject, Codable {
    var api: String? = ""
    var tag: String? = ""
    var community: String? = ""
    var code: String? = ""
    
    func getBidOrigin() -> BIDOrigin? {
        let bidOrigin = BIDOrigin()
        bidOrigin.api = self.api
        bidOrigin.tag = self.tag
        bidOrigin.community = self.community
        return bidOrigin
    }
}


 enum MagicLinkAuthType: String {
    case authn
    case otp
    case none
}

struct MagicLink {
    let url: String?
    let baseUrl: String?
    let code: String?
    let path: String?
}
