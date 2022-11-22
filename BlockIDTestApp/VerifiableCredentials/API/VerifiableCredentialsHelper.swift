//
//  VerifiableCredentialsHelper.swift
//  BlockIDTestApp
//
//  Created by Sushil Tiwari on 02/10/22.
//

import Foundation
import Alamofire
import BlockIDSDK

// define type of document using which the
// verifiable credentials will be created
public enum VerifiableCredential: String {
    // for now, only 'dl' is supported; others may be added in future
    case none = "none"
    
    // for now, only 'dl' is supported; others may be added in future
    case document_dl = "dl"
    
    // 'employment_card'
    case employment_card = "employment_card"
}

class VerifiableCredentialsHelper: NSObject {
    
    // define supported methods
    public enum VCMethod {
        // create vc
        case create
        
        // verify vc
        case verify
    }
    
    // private variables to hold vcs's api path
    private let kCreateVCFromDocument = "/tenant/{tenantId}/community/{communityId}/vc/from/document/{type}"
    private let kCreateVCFromPayload = "/tenant/{tenantId}/community/{communityId}/vc/from/payload/{type}"
    //private let kVerifyVC = "/tenant/{tenantId}/community/{communityId}/verify/vc"
    private let kVerifyVC = "/tenant/{tenantId}/community/{communityId}/vc/verify"
    
    private var sessionManager: SessionManager?
    private var serviceURL: String?
    private var publicKey: String?
    
    public static let shared = VerifiableCredentialsHelper()
    private override init() {
        super.init()
        
        // initialize session manager
        self.sessionManager = Alamofire.SessionManager.default
        self.sessionManager?.session.configuration.timeoutIntervalForRequest = 420
        self.sessionManager?.session.configuration.timeoutIntervalForResource = 600
    }
    
    public func createVerifiableCredentials(for type: VerifiableCredential,
                                            with document: [String: Any]?,
                                            completionHandler: @escaping ((result: [String: Any]?,
                                                                           error: Error?)) -> Void) {
        self.createVCFromDocument(type: type,
                                  document: document,
                                  completionHandler: completionHandler)
    }
    
    public func verify(vc document: [String: Any]?,
                       completionHandler: @escaping ((result: [String: Any]?,
                                                      error: Error?)) -> Void) {
        self.verifyVC(document: document,
                      completionHandler: completionHandler)
    }
}

// MARK: - Extension: Private Methods -
extension VerifiableCredentialsHelper {
    private func createVCFromDocument(type: VerifiableCredential,
                                      document: [String: Any]?,
                                      completionHandler: @escaping ((result: [String: Any]?,
                                                                     error: Error?)) -> Void) {
        // 1. access service directory to get 'vcs' URL
        // 2. get publicKey of 'vcs' URL
        // 3. check type
        // 4. based on payload, called respective API
        
        // access service directory to get 'vcs' URL
        let sharedSD = ServiceDirectory.sharedInstance
        sharedSD.getServiceDirectoryDetails(forTenant: AppConsant.defaultTenant) { (vcsResult, vcsError) in
            if vcsError == nil, let result = vcsResult, let vcsURL = result["vcs"] as? String {
                // service directory details available
                // 'vcs' url available; proceed to request publicKey
                sharedSD.getServicePublickey(serviceURL: vcsURL) { (pbkResult, pbKError) in
                    if pbKError == nil, let result = pbkResult, let publicKey = result["publicKey"] as? String {
                        // received 'publicKey'; get correct api path
                        let fullAPIPath = self.getCompleteAPIPath(for: vcsURL,
                                                                  type: type,
                                                                  method: VCMethod.create)
                        
                        // encrypt licene key
                        let encryptedLicenseKey = BlockIDSDK.sharedInstance.encryptString(str: AppConsant.licenseKey,
                                                                                          rcptKey: publicKey)!
                        
                        
                        
                        // encrypt requestID json string
                        let encryptedRequestID = BlockIDSDK.sharedInstance.encryptString(str: self.getRequestID(),
                                                                                         rcptKey: publicKey)!
                        
                        // get wallet's public key
                        let walletPublicKey = BlockIDSDK.sharedInstance.getWalletPublicKey()
                        
                        // setup required HTTP headers
                        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                                    "publickey": walletPublicKey,
                                                    "requestid": encryptedRequestID,
                                                    "licensekey": encryptedLicenseKey]
                        // trigger api request
                        self.sessionManager?.request(fullAPIPath,
                                                     method: HTTPMethod.post,
                                                     parameters: document,
                                                     encoding: JSONEncoding.default,
                                                     headers: headers).responseJSON { response in
                            switch response.result {
                            case .success:
                                // return the response received in as if form
                                // calling function must handle various status code
                                completionHandler((response.result.value as? [String: Any], nil))
                            case .failure (let responseError):
                                // internet connection error
                                // or any other failure
                                completionHandler((nil, responseError))
                            @unknown default:
                                // unknown failure
                                completionHandler((nil, nil))
                            }
                        }
                    } else {
                        completionHandler((pbkResult, pbKError))
                    }
                }
            } else {
                completionHandler((vcsResult, vcsError))
            }
        }
    }
    
    private func verifyVC(document: [String: Any]?,
                          completionHandler: @escaping ((result: [String: Any]?,
                                                         error: Error?)) -> Void) {
        // 1. access service directory to get 'vcs' URL
        // 2. get publicKey of 'vcs' URL
        // 3. call verify API to verify incoming payload
        
        // access service directory to get 'vcs' URL
        let sharedSD = ServiceDirectory.sharedInstance
        sharedSD.getServiceDirectoryDetails(forTenant: AppConsant.defaultTenant) { (vcsResult, vcsError) in
            if vcsError == nil, let result = vcsResult, let vcsURL = result["vcs"] as? String {
                // service directory details available
                // 'vcs' url available; proceed to request publicKey
                sharedSD.getServicePublickey(serviceURL: vcsURL) { (pbkResult, pbKError) in
                    if pbKError == nil, let result = pbkResult, let publicKey = result["publicKey"] as? String {
                        // received 'publicKey'; get correct api path
                        let fullAPIPath = self.getCompleteAPIPath(for: vcsURL,
                                                                  type: VerifiableCredential.none,
                                                                  method: VCMethod.verify)
                        // encrypt licene key
                        let encryptedLicenseKey = BlockIDSDK.sharedInstance.encryptString(str: AppConsant.licenseKey,
                                                                                          rcptKey: publicKey)!
                        
                        
                        
                        // encrypt requestID json string
                        let encryptedRequestID = BlockIDSDK.sharedInstance.encryptString(str: self.getRequestID(),
                                                                                         rcptKey: publicKey)!
                        
                        // get wallet's public key
                        let walletPublicKey = BlockIDSDK.sharedInstance.getWalletPublicKey()
                        
                        // setup required HTTP headers
                        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                                    "publickey": walletPublicKey,
                                                    "requestid": encryptedRequestID,
                                                    "licensekey": encryptedLicenseKey]
                        // trigger api request
                        self.sessionManager?.request(fullAPIPath,
                                                     method: HTTPMethod.post,
                                                     parameters: document,
                                                     encoding: JSONEncoding.default,
                                                     headers: headers).responseJSON { response in
                            switch response.result {
                            case .success:
                                // return the response received in as if form
                                // calling function must handle various status code
                                completionHandler((response.result.value as? [String: Any], nil))
                            case .failure (let responseError):
                                // internet connection error
                                // or any other failure
                                completionHandler((nil, responseError))
                            @unknown default:
                                // unknown failure
                                completionHandler((nil, nil))
                            }
                        }
                    } else {
                        completionHandler((pbkResult, pbKError))
                    }
                }
            } else {
                completionHandler((vcsResult, vcsError))
            }
        }
    }
}

// MARK: - Extension: Utility Methods -
extension VerifiableCredentialsHelper {
    private func getCompleteAPIPath(for vcsURL: String, type: VerifiableCredential, method: VCMethod) -> String {
        // create full API path based on verifiable credential type
        var apiPath: String = vcsURL
        
        if method == .verify {
            apiPath = apiPath + kVerifyVC
        } else if type != .none {
            apiPath = apiPath + ((type == .document_dl) ? kCreateVCFromDocument : kCreateVCFromPayload)
            apiPath = apiPath.replacingOccurrences(of: "{type}",
                                                   with: type.rawValue)
        }
        
        // get tenant details to update
        // 'tenantId' and 'communityId'
        if let currentTenant = BlockIDSDK.sharedInstance.getTenant(),
           let tenantId = currentTenant.tenantId,
           let communityId = currentTenant.communityId {
            // replace '{tenantId}'
            apiPath = apiPath.replacingOccurrences(of: "{tenantId}",
                                                   with: tenantId)
            // replace '{communityId}'
            apiPath = apiPath.replacingOccurrences(of: "{communityId}",
                                                   with: communityId)
        }
        
        return apiPath
    }
    
    private func getRequestID() -> String {
        var requestID = ""
        
        // generate requestID payload
        let payload: [String : Any] = ["ts": Int(Date().timeIntervalSince1970),
                                                "deviceId": UIDevice.current.identifierForVendor!.uuidString,
                                                "uuid": UUID().uuidString,
                                                "appid": Bundle.main.bundleIdentifier!]
        
        do {
            // convert requestID to json data
            let jSONData = try JSONSerialization.data(withJSONObject: payload,
                                                                options: [])
            // convert requestID json data to string
            if let requestid = String(data: jSONData, encoding: .utf8) {
                requestID = requestid
            }
        } catch {
            return requestID
        }
        
        return requestID
    }
}
