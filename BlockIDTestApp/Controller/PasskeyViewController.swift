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
    
    @IBOutlet weak var btnAuthenticate: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var textFieldUserName: UITextField?
    
    private var userName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldUserName?.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        btnRegister.isEnabled = !(self.textFieldUserName?.text ?? "").isEmpty
        btnAuthenticate.isEnabled = !(self.textFieldUserName?.text ?? "").isEmpty
    }
    
    @IBAction func doRegister(_ sender: Any) {
        BlockIDSDK.sharedInstance.fetchUserByUserName(tenant: Tenant.defaultTenant,
                                                      userName: userName) { status, response, error in
            if let responseString = response,
                let dictResponse = CommonFunctions.jsonStringToDic(from: responseString),
               let data = dictResponse["data"] as? [String: Any] {
                self.processPasskeyRegistration(userName: (data["dguid"] as? String) ?? "",
                                                displayName: (data["username"] as? String) ?? "")
            }
            
        }
    }
    
    @IBAction func doAuthenticate(_ sender: Any) {
        BlockIDSDK.sharedInstance.fetchUserByUserName(tenant: Tenant.defaultTenant,
                                                      userName: userName) { status, response, error in
            if let responseString = response,
                let dictResponse = CommonFunctions.jsonStringToDic(from: responseString),
               let data = dictResponse["data"] as? [String: Any] {
                self.processPasskeyAuthentication(userName: (data["dguid"] as? String) ?? "",
                                                displayName: (data["username"] as? String) ?? "")
            }
            
        }
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        userName = sender.text ?? ""
        btnRegister.isEnabled = sender.text?.count ?? 0 >= 3
        btnAuthenticate.isEnabled = sender.text?.count ?? 0 >= 3
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
