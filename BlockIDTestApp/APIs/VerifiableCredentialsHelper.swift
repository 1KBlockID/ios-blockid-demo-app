//
//  VerifiableCredentialsHelper.swift
//  BlockIDTestApp
//
//  Created by Sushil Tiwari on 02/10/22.
//

import Foundation
import Alamofire
import BlockIDSDK

class VerifiableCredentialsHelper: NSObject {
    
    private let kCreateVCFromDocument = "/tenant/{tenantId}/community/{communityId}/vc/from/document/{type}"
    private let kCreateVCFromPayload = "/tenant/{tenantId}/community/{communityId}/vc/from/payload/{type}"
    private let kVerifyVC = "/tenant/{tenantId}/community/{communityId}/verify/vc"
    
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
    
    public func createVerifiableCredentialsFromDocument(document: [String: Any]?,
                                                        serviceURL url: String?,
                                                        publicKey pbKey: String?,
                                                        completionHandler: @escaping ((result: [String: Any]?,
                                                                                       error: Error?)) -> Void) {
        if let currentTenant = BlockIDSDK.sharedInstance.getTenant(),
           let parameters = document,
           let serviceURL = url {
            var urlPath = serviceURL + kCreateVCFromDocument
            urlPath = urlPath.replacingOccurrences(of: "{type}",
                                                   with: "dl")
            
            if let tenantId = currentTenant.tenantId {
                urlPath = urlPath.replacingOccurrences(of: "{tenantId}",
                                                       with: tenantId)
            }
            
            if let communityId = currentTenant.communityId {
                urlPath = urlPath.replacingOccurrences(of: "{communityId}",
                                                       with: communityId)
            }
            
            let keyPair = APIKeyPair(privateKey: BlockIDSDK.sharedInstance.getWalletPrivateKey(),
                                     publicKey: BlockIDSDK.sharedInstance.getWalletPublicKey(),
                                     serverKey: pbKey!,
                                     licenseKey: BlockIDSDK.sharedInstance.getLicenseKey())
            
            let headers: HTTPHeaders = ["Content-Type": "application/json",
                                        "publickey": BlockIDSDK.sharedInstance.getWalletPublicKey(),
                                        "requestid": keyPair.generateRequestID()!,
                                        "licensekey": keyPair.getEncryptedLicenseKey()!]

            self.sessionManager?.request(urlPath,
                                         method: HTTPMethod.post,
                                         parameters: document,
                                         encoding: JSONEncoding.default,
                                         headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    // return the response received in as if form
                    // calling function must handle various status code
                    completionHandler((response.result.value as? [String: Any], nil))
                case .failure (let error):
                    // internet connection error
                    // or any other failure
                    completionHandler((nil, error))
                }
            }
        }
    }

//    public func getServiceDirectoryDetails(forTenant tenant: BIDTenant,
//                                           completionHandler: @escaping ((result: [String: Any]?,
//                                                                          error: Error?)) -> Void) {
//        if let dns = tenant.dns {
//            let url = dns + kServiceDirectory
//
//            let headers: HTTPHeaders = ["Content-Type": "application/json"]
//
//            self.sessionManager?.request(url,
//                                         method: HTTPMethod.get,
//                                         parameters: nil,
//                                         encoding: JSONEncoding.default,
//                                         headers: headers)
//            .responseJSON { response in
//                switch response.result {
//                case .success:
//                    // return the response received in as if form
//                    // calling function must handle various status code
//                    completionHandler((response.result.value as? [String: Any], nil))
//                case .failure (let error):
//                    // internet connection error
//                    // or any other failure
//                    completionHandler((nil, error))
//                }
//            }
//        }
//    }
    
//    public func getServicePublickey(serviceURL: String,
//                                    completionHandler: @escaping ((result: [String: Any]?,
//                                                                   error: Error?)) -> Void) {
//        let url = serviceURL + kPublicKeys
//        let headers: HTTPHeaders = ["Content-Type": "application/json"]
//
//        self.sessionManager?.request(url,
//                                     method: HTTPMethod.get,
//                                     parameters: nil,
//                                     encoding: JSONEncoding.default,
//                                     headers: headers)
//        .responseJSON { response in
//            switch response.result {
//            case .success:
//                // return the response received in as if form
//                // calling function must handle various status code
//                completionHandler((response.result.value as? [String: Any], nil))
//            case .failure (let error):
//                // internet connection error
//                // or any other failure
//                completionHandler((nil, error))
//            }
//        }
//    }
    
}
