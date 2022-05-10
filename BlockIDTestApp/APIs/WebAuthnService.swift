//
//  WebAuthnService.swift
//  BlockIDTestApp
//
//  Created by Vinoth Baskaran on 09/05/22.
//

import Foundation
import BlockIDSDK
import Alamofire

public class WebAuthnService {
    public let authSelection: [String: Any] = [
        "authenticatorAttachment" : "cross-platform",
        "userVerification": "required"
    ]
    public var request_options: [String: Any];
    private let LICENSE_KEY = "3f2282e9-3d46-4961-b103-a9319ad4560c";
    
    init() {
        let TENANT_ID = "5f3d8d0cd866fa61019cf968";
        let COMMUNITY_ID = "5f3d8d0cd866fa61019cf969";
        let DNS = "1k-dev.1kosmos.net";
        
        request_options = [
            "dns" : DNS,
            "username" : "iosclient",
            "displayName" : "iosclient",
            "tenantId" : TENANT_ID,
            "communityId" : COMMUNITY_ID,
            "attestation": "direct",
            "authenticatorSelection": authSelection
        ]
    }

    public func updateSession() {
        BlockIDSDK.sharedInstance.generateNewSession(tenantDNS: Tenant.defaultTenant.dns!,
                                                        communityName: Tenant.defaultTenant.community!) {
            status, msg, error, sessionId in

            if !status {
                print ("session update failed")
                return
            }
            print ("Session ID: " + (sessionId ?? ""))
        }
    }
    
    public func registerOptions(url: String = "https://httpbin.org/post", completion: @escaping ((_ response: AttestationOption?, _ message: String?, _ isSuccess: Bool) -> Void)) {
        guard let requestID = BlockIDSDK.sharedInstance.getRequestID() else {
            completion(nil, "Error reading requestID", false)
            return
        }
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "licensekey" : LICENSE_KEY,
            "requestid" : requestID
        ]
        Alamofire.request(url, method: .post, parameters: request_options, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { [self] response in
                switch response.result {
                case .success:
                    guard let data = response.data, let options = AttestationOptionResponse(response: data) else {
                        completion(nil, "Error reading attestation option", true)
                        return
                    }
                    print (data.prettyJson())
                    completion(options.attestationOption, nil, true)

                case .failure(let error):
                    print(error)
                    if let data = response.data {
                        print (data.prettyJson())
                    }
                    completion(nil, "error", false)
                @unknown default:
                    completion(nil, "error", false)
                }
        }
    }
}

extension Data {
    func prettyJson() -> String {
        do {
            let json =  try JSONSerialization.data(withJSONObject: jsonObjectWithData(), options: .prettyPrinted)
            return String(decoding: json, as: UTF8.self)
        } catch {}
        return ""
    }
    
    func jsonObjectWithData() -> [String : Any] {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as! [String : Any]
        } catch {}
        return [:]
    }
}
