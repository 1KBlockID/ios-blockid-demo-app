//
//  AppConstants.swift
//  ios-kernel
//
//  Created by Manik Kakar on 5/24/20.
//  Copyright © 2020 1Kosmos. All rights reserved.
//

import Foundation
import BlockIDSDK

public class Tenant : NSObject {
    static let licenseKey = "5809b7b7-886f-4c88-9061-59a2baf485be"
    static let defaultTenant = BIDTenant.makeTenant(tag: "1kosmos", community: "default", dns: "https://1k-dev.1kosmos.net")
    static let clientTenant = BIDTenant.makeTenant(tag: "1kosmos", community: "default", dns: "https://1k-dev.1kosmos.net")
}

public class AppConsant: NSObject {
    static let buildVersion = "buildVersion"
    static let appVersionKey = "appVersionKey"
}
