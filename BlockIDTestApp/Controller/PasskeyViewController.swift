//
//  PasskeyViewController.swift
//  1Kosmos Demo
//
//  Created by Prasanna Gupta on 19/08/25.
//

import UIKit
import AuthenticationServices

class PasskeyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doRegister(_ sender: Any) {
        self.registerPasskey()
    }
    
    @IBAction func doAuthenticate(_ sender: Any) {
        self.signInWithPasskey(challengeBase64Url: "I4kZ2uIhowLR6W0dLTDVhP3ZBdiHsMBvd_hStZXmLOM")
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func registerPasskey() {
        let challengeData = Data("srE92KlDQKJzycDpJsd3y2EIEtYGXlkClmup0mTcJEw".utf8)
        let userID = Data("rnjSNw2n-txpJGqVBu5XXoGtazag4yWt7odPFx41LHo".utf8)
        
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "1k-dev.1kosmos.net")
        let request = provider.createCredentialRegistrationRequest(challenge: challengeData, name: "pankti", userID: userID)
        
        //        request.userName = "pankti"
        request.displayName = "panktimistry"
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    private func signInWithPasskey(challengeBase64Url: String) {
        // Convert challenge (base64url string) into Data
        guard let challengeData = Data(base64URLEncoded: challengeBase64Url) else {
            print("Invalid challenge")
            return
        }
        
        // 1. Create the provider with your relying party ID (domain)
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "1k-dev.1kosmos.net")
        
        // 2. Create assertion request with the server challenge
        let request = provider.createCredentialAssertionRequest(challenge: challengeData)
        
        // 3. Ask system to perform the sign-in
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
            print("Attestation object: \(credential.rawAttestationObject?.base64EncodedString() ?? "nil")")
            print("ClientDataJSON: \(credential.rawClientDataJSON.base64EncodedString())")
        } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            print("Sign-in succeeded")
            print("AuthenticatorData: \(credential.rawAuthenticatorData.base64EncodedString())")
            print("ClientDataJSON: \(credential.rawClientDataJSON.base64EncodedString())")
            print("Signature: \(credential.signature.base64EncodedString())")
            print("UserID: \(String(data: credential.userID, encoding: .utf8) ?? "nil")")
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
