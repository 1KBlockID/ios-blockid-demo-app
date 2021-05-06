//
//  CommonFunctions.swift
//  BlockIDTestApp
//
//  Created by vaidehi hindlekar on 05/05/21.
//

import Foundation
class CommonFunctions {
    
    static func getAppBundleVersion() -> (String, String) {
        let appVer = getAppVersion()
        let bundleVer = getBundleVersionHex()
        return (appVer, bundleVer)
    }
    
    private static func getAppVersion() -> String {
        var appVersion = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        return appVersion
    }
    
    private static func getBundleVersionHex() -> String {
        var hexBundleVersion = ""
        if let bVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            hexBundleVersion = String(format:"%02X", Int(bVersion)!)
        }
        return hexBundleVersion
    }

}
