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
        
        print("ENCRP", encryptionStr)
        let payload = CommonFunctions.jsonStringToDic(from: dataReq)
        print("PAYLOAED<<<", payload)
        
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
    
    public func fetchServerPublicKey(completion: @escaping (_ publicKey: String) -> ()) {
        
        let url = baseURL + "publickeys"
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"])
            .responseJSON { response in
                
                switch response.result {
                case .success:
                  
                    guard let data = response.data else {
                        //completion((response.response?.statusCode, response.result.error, nil))
                        return
                    }
                    do {
                        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                            print("PUBLIC KEY<<<", jsonResult)
                            self.publicKey = jsonResult["publicKey"] as! String
                            completion(self.publicKey)
                        }
                    } catch(let error) {
                        print("ERROR", error)
                    }
                    
                case .failure(let error):
                    print("ERORR", error)
                }
                
            }
    }
    
}


