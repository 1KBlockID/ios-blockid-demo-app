//
//  AppConstants.swift
//  ios-kernel
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import BlockID

public class Tenant : NSObject {
    static let licenseKey = "5809b7b7-886f-4c88-9061-59a2baf485be"
    static let defaultTenant = BIDTenant.makeTenant(tag: "1kosmos", community: "default", dns: "https://1k-qa.1kosmos.net")
    static let clientTenant = BIDTenant.makeTenant(tag: "blockiddev-1kosmos", community: "default", dns: "https://blockid-dev.1kosmos.net")
}

public class AppConsant: NSObject {
    static let buildVersion = "buildVersion"
    static let appVersionKey = "appVersionKey"
    static let dvcID = "default_config"
    static let fidoUserName = "fidoUserName"
}
