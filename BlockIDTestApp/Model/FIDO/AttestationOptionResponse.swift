//
//  AttestationOptionResponse.swift
//  BlockIDTestApp
//
//  Created by Vinoth Baskaran on 10/05/22.
//

import Foundation

final class AttestationOptionResponse: NSObject {
    private(set) var attestationOption: AttestationOption

    public init? (response: Data) {
        do {
            guard let responseDictionary = try JSONSerialization.jsonObject(with: response) as? Dictionary<String, Any> else {
                return nil
            }
            guard let status = responseDictionary["status"] as? String else { return nil }
            guard status == "ok" else { return nil }
            
            guard let userDictionary = responseDictionary["user"] as? Dictionary<String, Any> else { return nil }
            guard let rpDictionary = responseDictionary["rp"] as? Dictionary<String, Any> else { return nil }
            guard let pubKeyCredParamsArray = responseDictionary["pubKeyCredParams"] as? Array<Dictionary<String, Any>> else { return nil }
            guard let authenticatorSelectionDictionary = responseDictionary["authenticatorSelection"] as? Dictionary<String, Any> else { return nil }

            guard let respUsername = userDictionary["name"] as? String else { return nil }
            guard let respUserId = userDictionary["id"] as? String else { return nil }
            
            guard let resRpId = rpDictionary["id"] as? String else { return nil }
            guard let respRpName = rpDictionary["name"] as? String else { return nil }
            
            guard let alg = pubKeyCredParamsArray[0]["alg"] as? Int else { return nil }
                        
            guard let respChallenge = responseDictionary["challenge"] as? String else { return nil }
            self.attestationOption = AttestationOption(challenge: respChallenge, rpId: resRpId, rpName: respRpName, userId: respUserId, userName: respUsername, pubKeyAlg: alg)
        } catch _ {
            return nil
        }
        super.init()
    }
}

public struct AttestationOption {
    let challenge: String
    let rpId: String
    let rpName: String
    let userId: String
    let userName: String
    let pubKeyAlg: Int
}
