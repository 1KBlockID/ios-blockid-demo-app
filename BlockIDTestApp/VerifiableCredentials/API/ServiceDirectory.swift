//
//  AccessServiceDirectory.swift
//  BlockIDTestApp
//
//  Created by Sushil Tiwari on 01/10/22.
//

import Foundation
import Alamofire
import BlockIDSDK

class ServiceDirectory: NSObject {
    
    private let kServiceDirectory = "/caas/sd"
    private let kPublicKeys = "/publickeys"
    
    private var sessionManager: SessionManager?
    
    public static let sharedInstance = ServiceDirectory()
    private override init() {
        super.init()
        
        // initialize session manager
        self.sessionManager = Alamofire.SessionManager.default
        self.sessionManager?.session.configuration.timeoutIntervalForRequest = 420
        self.sessionManager?.session.configuration.timeoutIntervalForResource = 600
    }

    public func getServiceDirectoryDetails(forTenant tenant: BIDTenant,
                                           completionHandler: @escaping ((result: [String: Any]?,
                                                                          error: Error?)) -> Void) {
        if let dns = tenant.dns {
            let url = dns + kServiceDirectory
            
            let headers: HTTPHeaders = ["Content-Type": "application/json"]
            
            self.sessionManager?.request(url,
                                         method: HTTPMethod.get,
                                         parameters: nil,
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
                @unknown default:
                    // unknown failure
                    completionHandler((nil, nil))
                }
            }
        }
    }
    
    public func getServicePublickey(serviceURL: String,
                                    completionHandler: @escaping ((result: [String: Any]?,
                                                                   error: Error?)) -> Void) {
        let url = serviceURL + kPublicKeys
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        
        self.sessionManager?.request(url,
                                     method: HTTPMethod.get,
                                     parameters: nil,
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
            @unknown default:
                // unknown failure
                completionHandler((nil, nil))
            }
        }
    }
    
}
