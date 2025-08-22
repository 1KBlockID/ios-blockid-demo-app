//
//  PasskeyViewController.swift
//  1Kosmos Demo
//
//  Created by Prasanna Gupta on 19/08/25.
//

import UIKit
import AuthenticationServices
import BlockID

class PasskeyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doRegister(_ sender: Any) {
        let passketReq = PasskeyRequest(tenant: Tenant.defaultTenant,
                                        username: "Prasanna",
                                        displayName: "Prasanna Gupta")
        BlockIDSDK.sharedInstance.registerPasskey(controller: self,
                                                  passkeyRequest: passketReq) { status, response, error in
            debugPrint("Prasanna: PasskeyViewController registerPasskey", #function, status, response, error?.message)
        }
       /* let webauthnURL = "https://1k-dev.1kosmos.net/webauthn"
        let webAuthNPubKey = "8a7O4b7Q46BPHKrMjfZhl/azy4eOT1rKDI3NmQIYenDcm4uVyu95wqWl4EHRD86aKmc2y00KWrasWTrc/QzqWg=="
        
        BlockIDSDK.sharedInstance.getAttestationOptionsAPI(
            webauthnURL: webauthnURL,
            webAuthNPubKey: webAuthNPubKey) {
                (status, message, error, options) in
                if !status {
                    print("❌ API failed")
                    print("Message: \(message)")
                    if let err = error {
                        print("Error details: \(err)")
                    }
                } else {
                    print("✅ API succeeded")
                    print("Message: \(message)")
                    
                    if let attestationOptions = options,
                       let jsonData = try? JSONEncoder().encode(attestationOptions),
                       let jsonStr = String(data: jsonData, encoding: .utf8) {
                        print("📄 AttestationOptionsData JSON:\n\(jsonStr)")
                        
                        self.registerPasskey(option: options)
                    }
                }
            }*/
    }
    
    @IBAction func doAuthenticate(_ sender: Any) {
        
       /* let webauthnURL = "https://1k-dev.1kosmos.net/webauthn"
        let webAuthNPubKey = "8a7O4b7Q46BPHKrMjfZhl/azy4eOT1rKDI3NmQIYenDcm4uVyu95wqWl4EHRD86aKmc2y00KWrasWTrc/QzqWg=="
        
        BlockIDSDK.sharedInstance.getAssertionOptionsAPI(
            webauthnURL: webauthnURL,
            webAuthNPubKey: webAuthNPubKey
        ) { (status, message, error, options) in
            
            if !status {
                print("❌ API failed")
                print("Message: \(message)")
                if let err = error {
                    print("Error details: ", err.code, err.message)
                }
            } else {
                print("✅ API succeeded")
                print("Message: \(message)")
                
                if let assertionOptions = options {
                    // Debug print
                    print("Assertion Options: \(assertionOptions)")
                    
                    // If you want JSON for debugging
                    if let jsonData = try? JSONEncoder().encode(assertionOptions),
                       let jsonStr = String(data: jsonData, encoding: .utf8) {
                        print("📄 AssertionOptionsData JSON:\n\(jsonStr)")
                    }
                    
                    self.signInWithPasskey(options: options)
                }
            }
        }*/
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func registerPasskey(option: AttestationOptionsData?) {
        guard let option = option,
              let challengeB64 = option.challenge,
              let user = option.user,
              let rp = option.rp else {
            print("❌ Missing required attestation options")
            return
        }
        guard let challengeData = Data(base64Encoded: challengeB64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            .padding(toLength: ((challengeB64.count+3)/4)*4, withPad: "=", startingAt: 0)) else {
            print("❌ Failed to decode challenge")
            return
        }
        
        // Decode user.id (base64url → Data)
        var userIdData = Data()
        if let userIdStr = user.id {
            userIdData = Data(base64Encoded: userIdStr
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
                .padding(toLength: ((userIdStr.count+3)/4)*4, withPad: "=", startingAt: 0)) ?? Data()
        }
        
        // Relying Party ID from rp
        let rpID = rp.id ?? "1k-dev.1kosmos.net"   // fallback
        
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpID)
        
        
        let request = provider.createCredentialRegistrationRequest(
            challenge: challengeData,
            name: user.name ?? "",
            userID: userIdData
        )
        
        request.displayName = user.displayName ?? user.name ?? "Unknown User"
        
        // ✅ Handle excludeCredentials
        if let excludeList = option.excludeCredentials, !excludeList.isEmpty {
            let descriptors: [ASAuthorizationPlatformPublicKeyCredentialDescriptor] = excludeList.compactMap { cred in
                guard let id = cred.id,
                      let credID = Data(base64URLEncoded: id) else {
                    return nil
                }
                return ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: credID)
            }
            
            if #available(iOS 17.4, *) {
                request.excludedCredentials = descriptors
            } else {
                // iOS < 17.4 → API not available
                // The OS won’t enforce exclusion, so rely on server-side enforcement
                // TBD with Sarthak and Prasanna
            }
        }

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func signInWithPasskey(options: AssertionOptionsData?) {
//        // Convert challenge (base64url string) into Data
//        guard let challengeData = Data(base64URLEncoded: challengeBase64Url) else {
//            print("Invalid challenge")
//            return
//        }
//
//        // 1. Create the provider with your relying party ID (domain)
//        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "1k-dev.1kosmos.net")
//
//        // 2. Create assertion request with the server challenge
//        let request = provider.createCredentialAssertionRequest(challenge: challengeData)

        guard let options = options,
              let challengeBase64Url = options.challenge,
              let rpId = options.rpId else {
            print("❌ Missing challenge or rpId")
            return
        }
        
        // Convert challenge (base64url string) into Data
        guard let challengeData = Data(base64URLEncoded: challengeBase64Url) else {
            print("❌ Invalid challenge")
            return
        }
        
        // 1. Create the provider with your relying party ID (domain from options.rpId)
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        
        // 2. Create assertion request with the server challenge
        let request = provider.createCredentialAssertionRequest(challenge: challengeData)
        
        // 3. If server sent allowCredentials → filter acceptable credentials
        if let allowList = options.allowCredentials, !allowList.isEmpty {
            let descriptors: [ASAuthorizationPlatformPublicKeyCredentialDescriptor] = allowList.compactMap { cred in
                guard let id = cred.id,
                      let credID = Data(base64URLEncoded: id) else {
                    return nil
                }
                return ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: credID)
            }
            request.allowedCredentials = descriptors
        }
        
        // 4. Ask system to perform the sign-in
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
}

// MARK: - ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding
extension PasskeyViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            print("Registration succeeded")
            
            let rawIdBase64URL = credential.credentialID.base64URLEncodedString()
            let clientDataJSON = credential.rawClientDataJSON.base64URLEncodedString()
            let attestationObject = credential.rawAttestationObject?.base64URLEncodedString() ?? ""
            
            print("Attestation object: \(credential.rawAttestationObject?.base64URLEncodedString() ?? "nil")")
            print("ClientDataJSON: \(credential.rawClientDataJSON.base64URLEncodedString())")
            
//               // Convert rawId to Base64URL (or regular Base64 for now)
//               let rawIdBase64 = credential.credentialID.base64EncodedString()
//               let clientDataJSON = credential.rawClientDataJSON.base64EncodedString()
//               let attestationObject = credential.rawAttestationObject?.base64EncodedString() ?? ""
            
            // Prepare response object
            let response = AttestationResultResponseRequest(
             clientDataJson: clientDataJSON,
             attestationObject: attestationObject
            )
            
            // Example constants - replace with your actual values
            let dns = "1k-dev.1kosmos.net"
            let tenantId = "68418b2587942f1d3158a798"
            let communityId = "68418b2587942f1d3158a799"
            
            // Prepare full request object
            let request = AttestationResultRequest(
             rawId: rawIdBase64URL,
             authenticatorAttachment: "platform", // always platform on iOS
             id: rawIdBase64URL,
             type: "public-key",
             dns: dns,
             communityId: communityId,
             tenantId: tenantId,
             response: response
            )
            
            // Debug log
            if let jsonData = try? JSONEncoder().encode(request),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 AttestationResultRequest JSON:\n\(jsonString)")
            }
            
            let webauthnURL = "https://1k-dev.1kosmos.net/webauthn"
            let webAuthNPubKey = "8a7O4b7Q46BPHKrMjfZhl/azy4eOT1rKDI3NmQIYenDcm4uVyu95wqWl4EHRD86aKmc2y00KWrasWTrc/QzqWg=="
            
            // Call the function
          /*  BlockIDSDK.sharedInstance.getAttestationResult(webauthnURL: webauthnURL,
                                                           webAuthNPubKey: webAuthNPubKey,
                                                           requestObj: request
            ) { status, message, error, result in
                if status {
                    if let data = result {
                        print("✅ Success: sub = \(data.sub ?? "nil"), authenticatorId = \(data.authenticatorId ?? "nil")")
                    } else {
                        print("⚠️ Success but no data returned")
                    }
                } else {
                    print("❌ Failed: \(message)")
                    if let err = error {
                        print("Error details: \(err)")
                    }
                }
            }*/
        } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            print("Sign-in succeeded")
            
            let authenticatorData = credential.rawAuthenticatorData.base64URLEncodedString()
            let clientDataJSON = credential.rawClientDataJSON.base64URLEncodedString()
            let signature = credential.signature.base64URLEncodedString()
            let userId = String(data: credential.userID, encoding: .utf8) ?? "nil"
            let credentialId = credential.credentialID.base64URLEncodedString()
            
            print("AuthenticatorData: \(authenticatorData)")
            print("ClientDataJSON: \(clientDataJSON)")
            print("Signature: \(signature)")
            print("UserID: \(userId)")
            print("CredentialID: \(credentialId)")
            
            
            let webauthnURL = "https://1k-dev.1kosmos.net/webauthn"
            let webAuthNPubKey = "8a7O4b7Q46BPHKrMjfZhl/azy4eOT1rKDI3NmQIYenDcm4uVyu95wqWl4EHRD86aKmc2y00KWrasWTrc/QzqWg=="
            
            
            let requestDict: [String: Any] = [
             "communityId": "68418b2587942f1d3158a799",
             "tenantId": "68418b2587942f1d3158a798",
             "id": credentialId,
             "rawId": credentialId,
             "type": "public-key",
             "response": [
                 "authenticatorData": authenticatorData,
                 "clientDataJSON": clientDataJSON,
                 "signature": signature,
                 "userHandle": userId
             ]
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: requestDict, options: [.prettyPrinted])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("📤 AssertionResultRequest JSON:\n\(jsonString)")
                }
            } catch {
                print("Error serializing JSON: \(error)")
            }
            
           /* BlockIDSDK.sharedInstance.getAssertionResult(webauthnURL: webauthnURL, webAuthNPubKey: webAuthNPubKey, requestDict: requestDict
            ) { status, message, error, result in
                if status {
                    if let data = result {
                        print("✅ Success: sub = \(data.sub ?? "nil"), authenticatorId = \(data.authenticatorId ?? "nil")")
                    } else {
                        print("⚠️ Success but no data returned")
                    }
                } else {
                    print("❌ Failed: \(message)")
                    if let err = error {
                        print("Error details: \(err)")
                    }
                }
            }*/
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ *Authorization failed: \(error.localizedDescription)", error)
        // Optional: check specific error type
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                print("User canceled sign in")
            case .failed:
                print("Authorization failed")
            case .invalidResponse:
                print("Invalid response from authorization")
            case .notHandled:
                print("Request not handled")
            case .unknown:
                print("Unknown error occurred")
            case .notInteractive:
                print("not Interactive")
            case .matchedExcludedCredential:
                print("matched Excluded Credential")
            @unknown default:
                print("Unhandled error case")
            }
        }
    }
}
