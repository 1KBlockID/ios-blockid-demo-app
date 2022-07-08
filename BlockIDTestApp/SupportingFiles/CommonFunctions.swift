//
//  CommonFunctions.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import UIKit
class CommonFunctions {
    
    static func getAppBundleVersion() -> (String, String) {
        let appVer = getAppVersion()
        let bundleVer = getBundleVersion()
        return (appVer, bundleVer)
    }
    
    private static func getAppVersion() -> String {
        var appVersion = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        return appVersion
    }
    
    private static func getBundleVersion() -> String {
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
    
    static func objectToJSONString<T>(_ value: T) -> String where T : Encodable {
        var ret : String?
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            ret = String(data: data, encoding: String.Encoding.utf8)
            
        } catch {
            debugPrint("some exception when converting object to JSON")
        }
        return ret!
    }
    
    static func convertJSONStringToJSONObject(_ jsonString: String) -> Any? {
        var object : Any?
        let data = Data(jsonString.utf8)
        do {
            object = try JSONSerialization.jsonObject(with: data)
        } catch {
            debugPrint("some exception when converting JSON to object")
            debugPrint(error)
        }

        return object
    }
    
    static func convertToJSONString(_ object: AnyObject) -> String {
        var jsonString : String?
        do {
           let jsonData = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions()) as NSData
            jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as String?
        } catch {
            debugPrint("some exception when converting object to JSON")
        }
        return jsonString!
    }
    
    
    static func convertImageFromBase64String(str: String) -> UIImage {
        let dataDecoded : Data = Data(base64Encoded: str, options: .ignoreUnknownCharacters)!
        guard let decodedimage = UIImage(data: dataDecoded) else {
            return UIImage()
        }
        return decodedimage
    }
    
    static func convertImageToBase64String(img: UIImage) -> String {
        return img.pngData()?.base64EncodedString() ?? ""
    }
    
    /**
     **JSON Serialized Object**
     *Converts json encoded string to dictionary to be used for requests*
     - Parameter json: json encoded string for request
     - Returns: Dictionary
     */
    static func jsonStringToDic(from json: String) -> [String: Any]? {
        guard let data = json.data(using: .utf8) else { return nil }
        let anyResult = try? JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: Any]
    }
}
