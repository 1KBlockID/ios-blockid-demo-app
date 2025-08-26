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
        let passkeyRequest = PasskeyRequest(tenant: Tenant.defaultTenant,
                                        username: "prasanna",
                                        displayName: "Prasanna Gupta")
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
}
