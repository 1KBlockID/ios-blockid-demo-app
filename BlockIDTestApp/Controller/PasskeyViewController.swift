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
        textFieldUserName?.delegate = self
        textFieldUserName?.becomeFirstResponder()
    }
    
    @IBAction func doRegister(_ sender: Any) {
        let passkeyRequest = PasskeyRequest(tenant: Tenant.defaultTenant,
                                        username: userName,
                                        displayName: userName)
        BlockIDSDK.sharedInstance.registerPasskey(controller: self,
                                                  passkeyRequest: passkeyRequest) { status, response, error in
            var toastMessage = "Error on Passkey registration! \(error?.message ?? "")"
            if status {
                toastMessage = "Passkey registered successfully!"
            }
            self.view.makeToast(toastMessage,
                                duration: 3.0,
                                position: .bottom)
        }
    }
    
    @IBAction func doAuthenticate(_ sender: Any) {
        let passkeyRequest = PasskeyRequest(tenant: Tenant.defaultTenant,
                                        username: "prasanna",
                                        displayName: "Prasanna Gupta")
        BlockIDSDK.sharedInstance.authenticatePasskey(controller: self,
                                                  passkeyRequest:  passkeyRequest) { status, response, error in
            var toastMessage = "Error on Passkey authentication! \(error?.message ?? "")"
            if status {
                toastMessage = "Passkey authenticated successfully!"
            }
            self.view.makeToast(toastMessage,
                                duration: 3.0,
                                position: .bottom)
        }
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        userName = sender.text ?? ""
        debugPrint("Prasanna: ", #function, sender.text?.count ?? 0 > 3)
        btnRegister.isEnabled = sender.text?.count ?? 0 > 3
        btnAuthenticate.isEnabled = sender.text?.count ?? 0 > 3
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        debugPrint("Prasanna: ", #function, #line)
        return true
    }
}
