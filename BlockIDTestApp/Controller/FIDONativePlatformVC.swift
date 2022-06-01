import Foundation
import WebAuthnKit
import PromiseKit

class FIDONativePlatformVC: FIDOViewController {
    var webAuthnClient: WebAuthnClient!
    var userConsentUI: UserConsentUI!
    private var sessionId:String?
    
    @IBAction override func authenticateTapped(_ sender: Any) {
        guard let username = self.txtFieldUsername.text,
              !username.isEmpty && !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let alert = UIAlertController(title: "Error", message: "User name can't be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
               // do nothing
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        WebAuthnService(username).authOptions(url: "https://1k-dev.1kosmos.net/webauthn/u1/assertion/options") {response, message, isSuccess in
            guard isSuccess, let options = response else {
                print ("Attestation options failed")
                return
            }
            var credOptions: PublicKeyCredentialRequestOptions = PublicKeyCredentialRequestOptions(
                challenge: Bytes.fromString(String (decoding: Data(base64URLEncoded: options.challenge)!, as: UTF8.self)),
                rpId: options.rpId, allowCredentials: [], userVerification: .required, timeout: 60000)
            for credentialId in options.allowCredentials {
                let id = Data(base64URLEncoded: credentialId)
                credOptions.addAllowCredential(credentialId: [UInt8] (id!),
                                               transports: [.internal_])
            }
            firstly {
                self.webAuthnClient.get(credOptions)
            }.done { assertion in
                var authResponse: AssertOnKeyAuthenticationResponse = AssertOnKeyAuthenticationResponse(credentialId: assertion.id, authenticatorData: Base64.encodeBase64URL(assertion.response.authenticatorData), clientDataJSON: Base64.encodeBase64URL(assertion.response.clientDataJSON.data(using: .utf8)!), signature: Base64.encodeBase64URL(assertion.response.signature), userId: assertion.id)
                WebAuthnService(username).authResult(url: "https://1k-dev.1kosmos.net/webauthn/u1/assertion/result",
                                                 sessionID: self.sessionId!, response: authResponse)
                    { response, message, isSuccess in
                        var alertMessage: String?
                        if isSuccess {
                            alertMessage = "User authentication success\n" + (message ?? "")
                        } else {
                            alertMessage = "Failed to authenticate, please try again later"
                        }
                        let alert = UIAlertController(title: "Authenticate", message: alertMessage!, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                           // do nothing
                        }))
                        self.present(alert, animated: true, completion: nil)
                }

            }.catch { error in
                print (error.localizedDescription)
                // error handling

              }
        }
    }
    
    @IBAction override func registerTapped(_ sender: Any) {
        guard let username = self.txtFieldUsername.text,
              !username.isEmpty && !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let alert = UIAlertController(title: "Error", message: "User name can't be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
               // do nothing
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        WebAuthnService(username).registerOptions(url: "https://1k-dev.1kosmos.net/webauthn/u1/attestation/options") {response, message, isSuccess in
            guard isSuccess, let options = response else {
                print ("Attestation options failed")
                return
            }
            print (options)
            var credOptions = PublicKeyCredentialCreationOptions()
            
            credOptions.challenge = Bytes.fromString(String(decoding: Data(base64URLEncoded: options.challenge)!, as: UTF8.self))
            credOptions.user.id = Bytes.fromString(options.userId)
            credOptions.user.name = options.userName
            credOptions.user.displayName = options.userName
            credOptions.rp.id = options.rpId
            credOptions.rp.name = options.rpName
            credOptions.attestation = .direct
            credOptions.addPubKeyCredParam(alg: .es256)
            credOptions.authenticatorSelection = AuthenticatorSelectionCriteria(
                requireResidentKey: true,
                userVerification: .required
            )
            firstly {
                self.webAuthnClient.create(credOptions)
            }.done { credential in
                print("==========================================")
                print("credentialId: " + credential.id)
                print("rawId: " + String(decoding: credential.rawId, as: UTF8.self))
                print("attestationObject: " + Base64.encodeBase64URL(credential.response.attestationObject))
                print("clientDataJSON: " + Base64.encodeBase64URL(credential.response.clientDataJSON.data(using: .utf8)!))
                print("==========================================")
                let response = AttestationResult(clientDataJSON: Base64.encodeBase64URL(credential.response.clientDataJSON.data(using: .utf8)!), attestationObject: Base64.encodeBase64URL(credential.response.attestationObject), rawid:
                    Base64.encodeBase64URL(credential.rawId), id: credential.id)
                WebAuthnService(username).registerResult(url: "https://1k-dev.1kosmos.net/webauthn/u1/attestation/result",
                                                 sessionID: self.sessionId!, response: response)
                    {response, message, isSuccess in
                        var alertMessage: String?
                        if isSuccess {
                            alertMessage = "User registration success\n" + (message ?? "")
                        } else {
                            alertMessage = "Failed to register, please try again later"
                        }
                        let alert = UIAlertController(title: "Registration", message: alertMessage!, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                           // do nothing
                        }))
                        self.present(alert, animated: true, completion: nil)
                }
            }.catch { error in
                print ("Error creating credential: " + error.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        setupWebAuthnClient()
        WebAuthnService().updateSession() {
            session in
            self.sessionId = session
        }
    }

    private func setupWebAuthnClient() {
        self.userConsentUI = UserConsentUI(viewController: self)
        let authenticator = InternalAuthenticator(ui: self.userConsentUI)
        self.webAuthnClient = WebAuthnClient(
            origin:        WebAuthnService.origin,
            authenticator: authenticator
        )
    }
}

