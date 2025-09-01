//
//  PasskeyViewController.swift
//  1Kosmos Demo
//
//  Created by Prasanna Gupta on 19/08/25.
//

import UIKit
import AuthenticationServices
import BlockID

class PasskeyViewController: UIViewController, UITextFieldDelegate {
    
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
        let passkeyRequest = PasskeyRequest(tenant: Tenant.defaultTenant,
                                        username: userName,
                                        displayName: userName)
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
    
    @IBAction func doAuthenticate(_ sender: Any) {
        let passkeyRequest = PasskeyRequest(tenant: Tenant.defaultTenant,
                                        username: userName,
                                        displayName: userName)
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
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        userName = sender.text ?? ""
        btnRegister.isEnabled = sender.text?.count ?? 0 >= 3
        btnAuthenticate.isEnabled = sender.text?.count ?? 0 >= 3
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
