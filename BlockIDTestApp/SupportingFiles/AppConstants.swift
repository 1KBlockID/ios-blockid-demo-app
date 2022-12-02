//
//  AppConstants.swift
//  ios-kernel
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import BlockIDSDK

public class Tenant : NSObject {
    static let licenseKey = "d2be2bd0-91e7-4374-9594-843f770bfa6c"
    static let defaultTenant = BIDTenant.makeTenant(tag: "1kosmos",
                                                    community: "default",
                                                    dns: "https://1k-pilot.1kosmos.net")
}

public class AppConsant: NSObject {
    static let buildVersion = "buildVersion"
    static let appVersionKey = "appVersionKey"
    static let dvcID = "composecure_09e2a012-d0ac-4695-a909-0b4d54198c58"
    static let fidoUserName = "fidoUserName"
}
