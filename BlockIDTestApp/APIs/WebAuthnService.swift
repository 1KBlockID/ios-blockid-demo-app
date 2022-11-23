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
    static let origin = "1k-dev.1kosmos.net"

    public let authSelection: [String: Any] = [
        "authenticatorAttachment" : "cross-platform",
        "userVerification": "required"
    ]
    public var request_options: [String: Any];
    private var sessionInfo: String?

//    public let TENANT_ID = "ten";
//    public let COMMUNITY_ID = "com";
//    public let DNS = "asf";
//    private let LICENSE_KEY = "123";
    private let TENANT_ID = "5f3d8d0cd866fa61019cf968";
    
    private let COMMUNITY_ID = "5f3d8d0cd866fa61019cf969";
    private let DNS = "1k-dev.1kosmos.net";
    private let LICENSE_KEY = "5809b7b7-886f-4c88-9061-59a2baf485be";
    
    private let USER_NAME: String
    private let DISPLAY_NAME: String

    init(_ userName: String = "") {
        USER_NAME = userName
        DISPLAY_NAME = userName.capitalized
        request_options = [
            "dns" : DNS,
            "username" : USER_NAME,
            "displayName" : DISPLAY_NAME,
            "tenantId" : TENANT_ID,
            "communityId" : COMMUNITY_ID,
            "attestation": "direct",
            "authenticatorSelection": authSelection
        ]
    }

    public func updateSession(completion: @escaping (String?) -> Void) {
        BlockIDSDK.sharedInstance.generateNewSession(tenantDNS: Tenant.defaultTenant.dns!,
                                                        communityName: Tenant.defaultTenant.community!) {
            status, msg, error, sessionId in

            if !status {
                print ("session update failed")
                return
            }
            print ("Session ID: " + (sessionId ?? ""))
            completion (sessionId)
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
            .responseJSON (){ [self] response in
                switch response.result {
                case .success:
                    guard let data = response.data, let options = AttestationOptionResponse(response: data) else {
                        completion(nil, "Error reading attestation option", true)
                        return
                    }
//                    print (data.prettyJson())
                    completion(options.attestationOption, nil, true)

                case .failure(let error):
                    print(error)
//                    if let data = response.data {
//                        print (data.prettyJson())
//                    }
                    completion(nil, "error", false)
                @unknown default:
                    completion(nil, "error", false)
                }
        }
    }
    
    public func registerResult(url: String = "https://httpbin.org/post", sessionID: String,
                               response: MakeCredentialOnKeyRegistrationResponse,
                               completion: @escaping ((_ response: AttestationOption?, _ message: String?, _ isSuccess: Bool) -> Void)) {
        guard let requestID = BlockIDSDK.sharedInstance.getRequestID() else {
            completion(nil, "Error reading requestID", false)
            return
        }
//        let headers: HTTPHeaders = [:]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "licensekey" : LICENSE_KEY,
            "requestid" : requestID,
            "sessionInfo": sessionID
        ]
        let attestation: [String: Any] = [
            "clientDataJSON": response.clientDataJSON.base64EncodedString(),
            "attestationObject": response.attestationObject.base64URLEncodedString(),
            "getTransports": [:],
            "getPublicKey" : [:],
            "getPublicKeyAlgorithm": [:],
            "getAuthenticatorData": [:]
        ]
        let request_results:[String: Any] = [
            "id": response.rawid,
            "rawId": response.rawid,
            "dns" : DNS,
            "tenantId" : TENANT_ID,
            "communityId" : COMMUNITY_ID,
            "getClientExtensionResults" : [:],
            "type" : "public-key",
            "authenticatorAttachment" : "cross-platform",
            "response": attestation,
        ]

        Alamofire.request(url, method: .post, parameters: request_results, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { [self] response in
                switch response.result {
                case .success:
//                    if let data = response.data {
//                        print (data.prettyJson())
//                    }
//                    guard let data = response.data, let options = AttestationOptionResponse(response: data) else {
//                        completion(nil, "Error reading attestation option", true)
//                        return
//                    }
                    completion(nil, response.data?.prettyJson() ?? "", true)

                case .failure(let error):
                    print(error)
//                    if let data = response.data {
//                        print (data.prettyJson())
//                    }
                    completion(nil, "error", false)
                @unknown default:
                    completion(nil, "error", false)
                }
        }
    }
    
    public func registerResult(url: String = "https://httpbin.org/post", sessionID: String,
                               response: AttestationResult,
                               completion: @escaping ((_ response: AttestationOption?, _ message: String?, _ isSuccess: Bool) -> Void)) {
        guard let requestID = BlockIDSDK.sharedInstance.getRequestID() else {
            completion(nil, "Error reading requestID", false)
            return
        }
//        let headers: HTTPHeaders = [:]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "licensekey" : LICENSE_KEY,
            "requestid" : requestID,
            "sessionInfo": sessionID
        ]
        let attestation: [String: Any] = [
            "clientDataJSON": response.clientDataJSON,
            "attestationObject": response.attestationObject,
            "getTransports": [:],
            "getPublicKey" : [:],
            "getPublicKeyAlgorithm": [:],
            "getAuthenticatorData": [:]
        ]
        let request_results:[String: Any] = [
            "id": response.id,
            "rawId": response.rawid,
            "dns" : DNS,
            "tenantId" : TENANT_ID,
            "communityId" : COMMUNITY_ID,
            "getClientExtensionResults" : [:],
            "type" : "public-key",
            "authenticatorAttachment" : "cross-platform",
            "response": attestation,
        ]

        Alamofire.request(url, method: .post, parameters: request_results, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { [self] response in
                switch response.result {
                case .success:
                    if let data = response.data {
                        completion(nil, data.prettyJson(), true)
                        return
                    }
                    completion(nil, "error", false)
                case .failure(let error):
                    print(error)
//                    if let data = response.data {
//                        print (data.prettyJson())
//                    }
                    completion(nil, "error", false)
                @unknown default:
                    completion(nil, "error", false)
                }
        }
    }

    public func authOptions(url: String = "https://1k-dev.1kosmos.net/webauthn/u1/assertion/options", completion: @escaping ((_ response: AssertionOption?, _ message: String?, _ isSuccess: Bool) -> Void)) {
        guard let requestID = BlockIDSDK.sharedInstance.getRequestID() else {
            completion(nil, "Error reading requestID", false)
            return
        }
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "licensekey" : LICENSE_KEY,
            "requestid" : requestID
        ]
        let auth_options: [String: Any] = [
            "dns" : DNS,
            "username" : USER_NAME,
            "displayName" : DISPLAY_NAME,
            "tenantId" : TENANT_ID,
            "communityId" : COMMUNITY_ID,
        ]

        Alamofire.request(url, method: .post, parameters: auth_options, encoding: JSONEncoding.default, headers: headers)
            .responseJSON (){ [self] response in
                switch response.result {
                case .success:
                    guard let data = response.data, let options = AssertionOptionResponse(response: data) else {
                        completion(nil, "Error reading attestation option", true)
                        return
                    }
//                    print (data.prettyJson())
                    completion(options.assertionOption, nil, true)

                case .failure(let error):
                    print(error)
//                    if let data = response.data {
//                        print (data.prettyJson())
//                    }
                    completion(nil, "error", false)
                @unknown default:
                    completion(nil, "error", false)
                }
        }
    }

    public func authResult(url: String = "https://1k-dev.1kosmos.net/webauthn/u1/assertion/result", sessionID: String,
                               response: AssertOnKeyAuthenticationResponse,
                               completion: @escaping ((_ response: AttestationOption?, _ message: String?, _ isSuccess: Bool) -> Void)) {
        guard let requestID = BlockIDSDK.sharedInstance.getRequestID() else {
            completion(nil, "Error reading requestID", false)
            return
        }
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "licensekey" : LICENSE_KEY,
            "requestid" : requestID,
            "sessionInfo": sessionID
        ]
        let attestation: [String: Any] = [
            "clientDataJSON": response.clientDataJSON,
            "authenticatorData": response.authenticatorData, // "authenticatorData"
            "signature": response.signature,
            "userHandle" : response.credentialId //user-id
        ]
        let request_results:[String: Any] = [
            "id": response.credentialId,
            "rawId": response.credentialId,
            "dns" : DNS,
            "tenantId" : TENANT_ID,
            "communityId" : COMMUNITY_ID,
            "getClientExtensionResults" : [:],
            "type" : "public-key",
            "authenticatorAttachment" : "cross-platform",
            "response": attestation,
        ]

        Alamofire.request(url, method: .post, parameters: request_results, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { [self] response in
                switch response.result {
                case .success:
                    if let data = response.data {
                        completion(nil, data.prettyJson(), true)
                        return
                    }
//                    if let data = response.data {
//                        print (data.prettyJson())
//                    }
//                    guard let data = response.data, let options = AttestationOptionResponse(response: data) else {
//                        completion(nil, "Error reading attestation option", true)
//                        return
//                    }
                    completion(nil, "error reading the response", true)

                case .failure(let error):
                    print(error)
//                    if let data = response.data {
//                        print (data.prettyJson())
//                    }
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
