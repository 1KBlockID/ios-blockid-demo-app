
import Foundation

class FIDONativeVC: FIDOViewController, YKFManagerDelegate, YKFFIDO2SessionKeyStateDelegate {
    var nfcConnection: YKFNFCConnection?
    var session: YKFFIDO2Session?
    var connectionCallback: ((_ connection: YKFConnectionProtocol) -> Void)?
    var accessoryConnection: YKFAccessoryConnection?

    func didConnectNFC(_ connection: YKFNFCConnection) {
        nfcConnection = connection
        if let callback = connectionCallback {
            callback(connection)
        }
    }

    func didFailConnectingNFC(_ error: Error) {
        connectionCallback = nil
//        print ("Connection " + error.localizedDescription)
    }
    
    func didCancelConnectingNFC(_ error: Error) {
//        connectionCallback = nil
        print ("Connection " + error.localizedDescription)
    }
    
    func didDisconnectNFC(_ connection: YKFNFCConnection, error: Error?) {
        nfcConnection = nil
        session = nil
    }

    func didConnectAccessory(_ connection: YKFAccessoryConnection) {
        accessoryConnection = connection
    }
    
    func didDisconnectAccessory(_ connection: YKFAccessoryConnection, error: Error?) {
        accessoryConnection = nil
        session = nil
    }

    func keyStateChanged(_ keyState: YKFFIDO2SessionKeyState) {
        if keyState == .touchKey {
            print ("Yubikey touch events")
        }
    }
    
    func connection(completion: @escaping (_ connection: YKFConnectionProtocol) -> Void) {
        if let connection = accessoryConnection {
            completion(connection)
        } else {
            connectionCallback = completion
            if #available(iOS 13.0, *) {
                YubiKitManager.shared.startNFCConnection()
            } else {
                // Fallback on earlier versions
            }
        }
    }

    func session(completion: @escaping (_ session: YKFFIDO2Session?, _ error: Error?) -> Void) {
        if let session = session {
            completion(session, nil)
            return
        }
        connection { connection in
            connection.fido2Session { session, error in
                self.session = session
                session?.delegate = self
                completion(session, error)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        YubiKitManager.shared.delegate = self
        if YubiKitDeviceCapabilities.supportsMFIAccessoryKey {
            YubiKitManager.shared.startAccessoryConnection()
        }
        let localizedAlertMessage = NSLocalizedString("Scan your SecurityKey", comment: "Scan your SecurityKey.")
        YubiKitExternalLocalization.nfcScanAlertMessage = localizedAlertMessage

        WebAuthnService().updateSession() {
            session in
            self.sessionId = session
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print ("Loading FIDONativeVC")
    }

    @IBAction override func authenticateTapped(_ sender: Any) {
        WebAuthnService().authOptions(url: "https://1k-dev.1kosmos.net/webauthn/u1/assertion/options") {response, message, isSuccess in
            guard isSuccess, let options = response else {
                print ("Assertion options failed")
                return
            }
            print (options)
            self.assertOnKey(response: options) { result in
                if #available(iOS 13.0, *) {
                    YubiKitManager.shared.stopNFCConnection()
                }
                switch result {
                case .success(let response):
                    print ("Yubikey Success")
                    DispatchQueue.main.async {
                        //url: "https://1k-dev.1kosmos.net/webauthn/u1/attestation/result"
                        WebAuthnService().authResult(url: "https://1k-dev.1kosmos.net/webauthn/u1/assertion/result",
                                                         sessionID: self.sessionId!, response: response)
                            {response, message, isSuccess in
                        }
                    }
//                    self.statusView?.state = .message("Finalising registration...")
                    // 3. Finalize WebAuthn registration
                case .failure(let error):
                    print ("Yubikey Failed: " + error.localizedDescription)
//                    self.statusView?.dismiss(message: "Error: \(error.localizedDescription)", accessory: .error, delay: 5.0)
                }
            }
        }
    }

    var sessionId: String?
    @IBAction override func registerTapped(_ sender: Any) {
        //url: "https://1k-dev.1kosmos.net/webauthn/u1/attestation/options"
        WebAuthnService().registerOptions(url: "https://1k-dev.1kosmos.net/webauthn/u1/attestation/options") {response, message, isSuccess in
            guard isSuccess, let options = response else {
                print ("Attestation options failed")
                return
            }
            print (options)
            self.makeCredentialOnKey(response: options) { result in
                if #available(iOS 13.0, *) {
                    YubiKitManager.shared.stopNFCConnection()
                }
                switch result {
                case .success(let response):
                    print ("Yubikey Success")
                    DispatchQueue.main.async {
                        //url: "https://1k-dev.1kosmos.net/webauthn/u1/attestation/result"
                        WebAuthnService().registerResult(url: "https://1k-dev.1kosmos.net/webauthn/u1/attestation/result",
                                                         sessionID: self.sessionId!, response: response)
                            {response, message, isSuccess in
                            
                        }
                    }
//                    self.statusView?.state = .message("Finalising registration...")
                    // 3. Finalize WebAuthn registration
                case .failure(let error):
                    print ("Yubikey Failed")
//                    self.statusView?.dismiss(message: "Error: \(error.localizedDescription)", accessory: .error, delay: 5.0)
                }
            }
        }
    }
}

extension FIDONativeVC {
    func handlePINCode(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(pinInputCompletion: { pin in
                guard let pin = pin else {
                    return
                }
                self.session { session, error in
                    guard let session = session else {
                        return
                    }
                    session.verifyPin(pin) { error in
                        guard error == nil else {
                            return
                        }
                        completion()
                    }
                }
            })
            self.present(alert, animated: true)
        }
    }

    func makeCredentialOnKey(response: AttestationOption,  completion: @escaping (Result<MakeCredentialOnKeyRegistrationResponse, Error>) -> Void) {
//        let challengeData = Data(response.challenge.utf8)
        let challengeData = Data(base64Encoded: response.challenge)!
        let clientData = YKFWebAuthnClientData(type: .create, challenge: challengeData, origin: WebAuthnService.origin)!
        
        let clientDataHash = clientData.clientDataHash!
        
        let rp = YKFFIDO2PublicKeyCredentialRpEntity()
        rp.rpId = response.rpId
        rp.rpName = response.rpName
        
        let user = YKFFIDO2PublicKeyCredentialUserEntity()
//        user.userId = Data(base64Encoded: response.userId)!
        user.userId = Data(response.userId.utf8)
        user.userName = response.userName
        
        let param = YKFFIDO2PublicKeyCredentialParam()
        param.alg = response.pubKeyAlg
        let pubKeyCredParams = [param]
        
        let options = [YKFFIDO2OptionRK: false]
        
        session { session, error in
            guard let session = session else { completion(.failure(error!)); return }
            session.makeCredential(withClientDataHash:clientDataHash,
                                   rp: rp,
                                   user: user,
                                   pubKeyCredParams: pubKeyCredParams,
                                   excludeList: nil,
                                   options: options)  { [self] keyResponse, error in
                guard error == nil else {
                    if let error = error as NSError?, error.code == YKFFIDO2ErrorCode.PIN_REQUIRED.rawValue {
                        handlePINCode() {
                            makeCredentialOnKey(response: response, completion: completion)
                        }
                        return
                    }
                    completion(.failure(error!))
                    return
                }
                
                guard let keyResponse = keyResponse, let id = keyResponse.authenticatorData?.credentialId?.base64URLEncodedString() else { fatalError() }
                let result = MakeCredentialOnKeyRegistrationResponse(clientDataJSON: clientData.jsonData!,
                                                                     attestationObject: keyResponse.webauthnAttestationObject,
                                                                     rawid: id)
                completion(.success(result))
            }
        }
    }
    
    func assertOnKey(response: AssertionOption, completion: @escaping (Result<AssertOnKeyAuthenticationResponse, Error>) -> Void) {
        session { session, error in
            guard let session = session else { completion(.failure(error!)); return }
            guard let challengeData = Data(base64Encoded: self.base64urlToBase64(base64url: response.challenge)) else {
                print ("Challenge is not base64 encoded")
                return
            }
            let clientData = YKFWebAuthnClientData(type: .get, challenge: challengeData, origin: WebAuthnService.origin)!
            
            let clientDataHash = clientData.clientDataHash!
            
            let rpId = response.rpId
            let options = [YKFFIDO2OptionUP: true]
            
            var allowList = [YKFFIDO2PublicKeyCredentialDescriptor]()
            for credentialId in response.allowCredentials {
                let credentialDescriptor = YKFFIDO2PublicKeyCredentialDescriptor()
                credentialDescriptor.credentialId = Data(base64Encoded: self.base64urlToBase64(base64url: credentialId))!
//                credentialDescriptor.credentialId = Data(credentialId.utf8)
                let credType = YKFFIDO2PublicKeyCredentialType()
                credType.name = "public-key"
                credentialDescriptor.credentialType = credType
                allowList.append(credentialDescriptor)
            }
            
            session.getAssertionWithClientDataHash(clientDataHash,
                                                   rpId: rpId,
                                                   allowList: allowList,
                                                   options: options) { assertionResponse, error in
                if #available(iOS 13.0, *) {
                    YubiKitManager.shared.stopNFCConnection()
                }
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                guard let assertionResponse = assertionResponse, let credential = assertionResponse.credential else { fatalError() }
                
                let userHandle: String = (assertionResponse.user != nil) ?
                        assertionResponse.user!.userId.base64URLEncodedString() :
                        credential.credentialId.base64URLEncodedString()
                let result = AssertOnKeyAuthenticationResponse(credentialId: credential.credentialId.base64URLEncodedString(),
                                                               authenticatorData: assertionResponse.authData.base64URLEncodedString(),
                                                               clientDataJSON: clientData.jsonData!.base64URLEncodedString(),
                                                               signature: assertionResponse.signature.base64URLEncodedString(),
                                                               userId: userHandle)
                completion(.success(result))
            }
        }
    }
    
    func base64urlToBase64(base64url: String) -> String {
        var base64 = base64url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return base64
    }
}

extension Data {
    public func base64URLEncodedString(options: Data.Base64EncodingOptions = []) -> String {
        return base64EncodedString(options: options).base64URLEscaped()
    }
}

extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String {
        guard let data = Data(base64Encoded: self) else { return self }
        return String(data: data, encoding: .utf8) ?? self
    }

    public func base64URLEscaped() -> String {
        return replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

extension UIAlertController {
    convenience init(pinInputCompletion:  @escaping (String?) -> Void) {
        self.init(title: "PIN verification required", message: "Enter the key PIN", preferredStyle: UIAlertController.Style.alert)
        addTextField { (textField) in
            textField.placeholder = "PIN"
            textField.isSecureTextEntry = true
        }
        addAction(UIAlertAction(title: "Verify", style: .default, handler: { (action) in
            let pin = self.textFields![0].text
            pinInputCompletion(pin)
        }))
        addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            pinInputCompletion(nil)
        }))
    }
}

// Wrap the fido2Session() Objective-C method in a more easy to use Swift version
extension YKFConnectionProtocol {
    func fido2Session(_ completion: @escaping ((_ result: Result<YKFFIDO2Session, Error>) -> Void)) {
        self.fido2Session { session, error in
            guard error == nil else { completion(.failure(error!)); return }
            guard let session = session else { fatalError() }
            completion(.success(session))
        }
    }
}
