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
    static let licenseKey = "afeb1c93-2265-43e1-a7b1-5049bb4f3c8b"
    static let defaultTenant = BIDTenant.makeTenant(tag: "1kosmos",
                                                    community: "default",
                                                    dns: "https://1k-il4.1kosmos-gov.net")
}

public class AppConsant: NSObject {
    static let buildVersion = "buildVersion"
    static let appVersionKey = "appVersionKey"
    static let dvcID = "default_config"
    static let fidoUserName = "fidoUserName"
}
