//
//  SessionAPI.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 01/06/22.
//

import Foundation
import BlockIDSDK
import Alamofire

class SessionAPI {
    
    //  - Singleton Object -
    static let sharedInstance = SessionAPI()
    // Computed Properties
    private let kDocumentSession = "document_share_session/create"
    private let kDocumentSessionResult = "document_share_session/result"
    private var baseURL: String {
        return "https://1k-dev.1kosmos.net/docuverify/"
    }
    private var publicKey: String = ""
    
    public func createSession(dvcID: String, dict: [String: Any], completion: @escaping ((_ object: DocumentSessionResponse?, _ error: ErrorResponse?) -> Void)) {
        
        let getDocumentSessionRequest = DocumentSessionRequest(dvcID: dvcID, sessionRequest: dict)
        
        let dataStr = CommonFunctions.objectToJSONString(getDocumentSessionRequest)
        
        guard let encryptionStr = BlockIDSDK.sharedInstance.encryptString(str: dataStr, rcptKey: self.publicKey) else {
            completion(nil, ErrorResponse(code: CustomErrors.kEncryption.code, msg: CustomErrors.kEncryption.msg))
            return
        }
        
        let dataReq = CommonFunctions.objectToJSONString(DataSessionRequest(data: encryptionStr))
        
        let payload = CommonFunctions.jsonStringToDic(from: dataReq)
        
        let url = baseURL + kDocumentSession
        let licenseKey = BlockIDSDK.sharedInstance.encryptString(str: Tenant.licenseKey, rcptKey: publicKey)
        guard let encryptedLicenseKey = licenseKey, let requestID = self.generateRequestID() else {
            completion(nil, ErrorResponse(code: CustomErrors.kEncryption.code, msg: CustomErrors.kEncryption.msg))
            return
        }
        let headers: [String: String] = ["licensekey": encryptedLicenseKey,
                                         "publickey": BlockIDSDK.sharedInstance.getWalletPublicKey(),
                                         "requestid": requestID,
                                         "Content-Type": "application/json"]
        
        
        Alamofire.request(url,
                          method: .post,
                          parameters: payload,
                          encoding: JSONEncoding.default,
                          headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        // completion((response.response?.statusCode, response.result.error, nil))
                        return
                    }
                    let decoder = JSONDecoder()
                    if let obj = try? decoder.decode(DocumentSessionResponse.self, from: data) {
                        completion(obj, nil)
                    }
                case .failure(let error):
                    print("error",error.localizedDescription)
                    //completion((error._code, error, nil))
                }
            }
        
    }
    
    private func generateRequestID() -> String? {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let ts = Date().timeIntervalSince1970
        
        let dict: [String : Any] = ["ts": Int(ts),
                                    "deviceId": UIDevice.current.identifierForVendor!.uuidString,
                                    "uuid": UUID().uuidString,
                                    "appid": bundleID]
        
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        let strToEncrypt = decoded
        return BlockIDSDK.sharedInstance.encryptString(str: strToEncrypt, rcptKey: self.publicKey)
    }
    
    public func fetchServerPublicKey(completion: @escaping (_ publicKey: String?, _ errorMsg: String?) -> ()) {
        
        let url = baseURL + "publickeys"
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"])
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    
                    guard let data = response.data else {
                        completion(nil, response.result.error?.localizedDescription)
                        return
                    }
                    do {
                        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                            self.publicKey = jsonResult["publicKey"] as! String
                            completion(self.publicKey, nil)
                        }
                    } catch(let error) {
                        completion(nil, error.localizedDescription)
                    }
                    
                case .failure(let error):
                    completion(nil, error.localizedDescription)
                }
                
            }
    }
    
    public func verifySession(dvcID: String, sessionID: String, publicKey: String, completion: @escaping ((DocumentSessionResult?, String?) -> Void)) {
        
        let verifySessionReq = VerifySessionRequest(sessionId: sessionID, dvcID: AppConsant.dvcID)
        let dataStr = CommonFunctions.objectToJSONString(verifySessionReq)
        
        guard let encryptionStr = BlockIDSDK.sharedInstance.encryptString(str: dataStr, rcptKey: publicKey) else {
            completion(nil, "Something went wrong with encrypting information")
            return
        }
        
        let dataReq = CommonFunctions.objectToJSONString(DataSessionRequest(data: encryptionStr))
        let payload = CommonFunctions.jsonStringToDic(from: dataReq)
        let url = baseURL + kDocumentSessionResult
        
        let licenseKey = BlockIDSDK.sharedInstance.encryptString(str: Tenant.licenseKey, rcptKey: publicKey)
        guard let encryptedLicenseKey = licenseKey, let requestID = self.generateRequestID() else {
            completion(nil, "Something went wrong with encrypting information")
            return
        }
        
        let headers: [String: String] = ["licensekey": encryptedLicenseKey,
                                         "publickey": BlockIDSDK.sharedInstance.getWalletPublicKey(),
                                         "requestid": requestID,
                                         "Content-Type": "application/json"]
        
        Alamofire.request(url, method: .post, parameters: payload, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        completion(nil, response.result.error?.localizedDescription)
                        return
                    }
                    
                    do {
                        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                            let dataStr = jsonResult["data"] as! String
                            let decryptedStr = BlockIDSDK.sharedInstance.decryptString(str: dataStr, senderKey: self.publicKey) ?? ""
                            let sessionResultObj = CommonFunctions.jsonStringToObject(json: decryptedStr) as DocumentSessionResult?
                            if sessionResultObj?.responseStatus?.lowercased() == "inprogress" {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                    self.verifySession(dvcID: dvcID, sessionID: sessionID, publicKey: publicKey, completion: completion)
                                })
                            } else if sessionResultObj?.responseStatus?.lowercased() == "success" {
                                completion(sessionResultObj, nil)
                            }
                            
                        }
                    } catch(let error) {
                        completion(nil, error.localizedDescription)
                    }
                    
                case .failure(let error):
                    completion(nil, error.localizedDescription)
                }
            }
        
    }
    
}


