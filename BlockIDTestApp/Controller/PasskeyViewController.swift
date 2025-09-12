//
//  PasskeyViewController.swift
//  1Kosmos Demo
//
//  Created by 1Kosmos Engineering
//  Copyright © 2025 1Kosmos. All rights reserved.
//

import UIKit
import AuthenticationServices
import BlockID

class PasskeyViewController: UIViewController {
    
    @IBOutlet weak var btnAuthenticatePasskey: UIButton?
    @IBOutlet weak var btnRegisterPasskey: UIButton?
    @IBOutlet weak var btnAuthPasskeyNGetJWT: UIButton?
    @IBOutlet weak var btnRegisterPasskeyAndLink: UIButton?
    @IBOutlet weak var textFieldUserName: UITextField?
    @IBOutlet weak var txtFieldPasskeyName: UITextField?
    @IBOutlet weak var btnCopyJWT: UIButton?
    @IBOutlet weak var lblJWT: UILabel?
    
    private var userName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldUserName?.becomeFirstResponder()
        btnCopyJWT?.isEnabled = true
        btnRegisterPasskeyAndLink?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        btnRegisterPasskey?.isEnabled = !(self.textFieldUserName?.text ?? "").isEmpty
        btnAuthenticatePasskey?.isEnabled = !(self.textFieldUserName?.text ?? "").isEmpty
        userName = "pgupta"
    }
    
    // MARK: - IBOutlets -
    @IBAction func doRegister(_ sender: Any) {
        self.textFieldUserName?.resignFirstResponder()
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.fetchUserByUserName(tenant: Tenant.defaultTenant,
                                                      userName: userName) { status, response, error in
            self.view.hideToastActivity()
            if status {
                guard let responseString = response,
                      let dictResponse = CommonFunctions.jsonStringToDic(from: responseString) else { return }
                if let data = dictResponse["data"] as? [String: Any] {
                    self.processPasskeyRegistration(userName: (data["dguid"] as? String) ?? "",
                                                    displayName: (data["username"] as? String) ?? "")
                }
            } else if error?.code == NSURLErrorNotConnectedToInternet ||
                        error?.code == CustomErrors.Network.OFFLINE.code {
                let localizedMessage = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
                self.showAlertView(title: ErrorConfig.noInternet.title,
                                   message: localizedMessage)
            } else if error?.code == 404 {
                let alertTitle = "No Account Found"
                let alertMessage = "We couldn’t find any account with \(self.userName)."
                self.showAlertView(title: alertTitle, message: alertMessage)
            } else {
                self.showAlertView(title: "Error",
                                   message: error?.message ?? "")
            }
        }
    }
    
    @IBAction func doAuthenticate(_ sender: Any) {
        self.textFieldUserName?.resignFirstResponder()
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.fetchUserByUserName(tenant: Tenant.defaultTenant,
                                                      userName: userName) { status, response, error in
            self.view.hideToastActivity()
            if status {
                guard let responseString = response,
                      let dictResponse = CommonFunctions.jsonStringToDic(from: responseString) else { return }
                
                if let data = dictResponse["data"] as? [String: Any] {
                    self.processPasskeyAuthentication(userName: (data["dguid"] as? String) ?? "",
                                                      displayName: (data["username"] as? String) ?? "")
                }
            } else if error?.code == NSURLErrorNotConnectedToInternet || error?.code == CustomErrors.Network.OFFLINE.code {
                let localizedMessage = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
                self.showAlertView(title: ErrorConfig.noInternet.title,
                                   message: localizedMessage)
            } else if error?.code == 404 {
                let alertTitle = "No Account Found"
                let alertMessage = "We couldn’t find any account with \(self.userName)."
                self.showAlertView(title: alertTitle, message: alertMessage)
            } else {
                self.showAlertView(title: "Error",
                                   message: error?.message ?? "")
            }
        }
    }
    
    @IBAction func goBack(_ sender: UIButton?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        userName = sender.text ?? ""
        let isEnabled = userName.count >= 3
        btnRegisterPasskey?.isEnabled = isEnabled
        btnAuthenticatePasskey?.isEnabled = isEnabled
        btnRegisterPasskeyAndLink?.isEnabled = isEnabled
        btnAuthPasskeyNGetJWT?.isEnabled = isEnabled
    }
    
    @IBAction func registerPasskeyAndLinkAccount(_ sender: UIButton) {
        let passkeyRequest = PasskeyRequest(tenant: Tenant.defaultTenant,
                                            username: userName,
                                            deviceName: "Prasanna' iPhoneXR_iOS18")
        BlockIDSDK.sharedInstance.registerPasskeywithAccountLinking(controller: self,
                                                                    passkeyRequest: passkeyRequest) {
            status, response, error in
            debugPrint("Prasanna: ", #function, status, response, error?.code, error?.message)
        }
    }
    
    @IBAction func authenticatePasskeyAndGetJWT(_ sender: UIButton) {
        
    }
    
    @IBAction func copyJWT(_ sender: UIButton) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = lblJWT?.text ?? ""
        self.view.makeToast("JWT Copied.", duration: 3.0, position: .center)

    }
}

extension PasskeyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

extension PasskeyViewController {
    fileprivate func processPasskeyAuthentication(userName: String, displayName: String) {
        let passkeyRequest = PasskeyRequest(tenant: Tenant.defaultTenant,
                                            username: userName,
                                            displayName: displayName)
        BlockIDSDK.sharedInstance.authenticatePasskey(controller: self,
                                                      passkeyRequest:  passkeyRequest) { status, response, error in
            if error?.code == NSURLErrorNotConnectedToInternet || error?.code == CustomErrors.Network.OFFLINE.code {
                let localizedMessage = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
                self.showAlertView(title: ErrorConfig.noInternet.title,
                                   message: localizedMessage)
                return
            }
            var alertTitle = "Passkey verification failed"
            var alertMessage = "We couldn’t verify passkey with \(self.userName). Please try again."
            if status {
                alertTitle = "Success"
                alertMessage = "Passkey verification successful for \(self.userName) \n Authenticator ID : \(response?.authenticatorId ?? "")"
            }
            self.showAlertView(title: alertTitle, message: alertMessage)
        }
    }
    
    fileprivate func processPasskeyRegistration(userName: String, displayName: String) {
        let passkeyRequest = PasskeyRequest(tenant: Tenant.defaultTenant,
                                            username: userName,
                                            displayName: displayName)
        BlockIDSDK.sharedInstance.registerPasskey(controller: self,
                                                  passkeyRequest: passkeyRequest) { status, response, error in
            if error?.code == NSURLErrorNotConnectedToInternet || error?.code == CustomErrors.Network.OFFLINE.code {
                let localizedMessage = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
                self.showAlertView(title: ErrorConfig.noInternet.title,
                                   message: localizedMessage)
                return
            }
            var alertTitle = "Passkey registration failed"
            var alertMessage = "We couldn’t register passkey with \(self.userName). Please try again."
            if status {
                alertTitle = "Success"
                alertMessage = "Passkey registration successful for \(self.userName) \n Authenticator ID : \(response?.authenticatorId ?? "")"
            }
            self.showAlertView(title: alertTitle, message: alertMessage)
        }
    }
}
