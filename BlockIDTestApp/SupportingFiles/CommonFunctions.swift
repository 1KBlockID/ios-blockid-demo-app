//
//  CommonFunctions.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
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

    static func jsonStringToObject<T>(json: String) -> T? where T : Decodable {
        do {
            let data = json.data(using: .utf8)!
            let decoder = JSONDecoder()
            let ret = try decoder.decode(T.self, from: data)
            return ret
        } catch {
        }
        
        return nil
    }
}
