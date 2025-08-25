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
    }
    
    @IBAction func doAuthenticate(_ sender: Any) {
        let passketReq = PasskeyRequest(tenant: Tenant.defaultTenant,
                                        username: "Prasanna",
                                        displayName: "Prasanna Gupta")
        BlockIDSDK.sharedInstance.authenticatePasskey(controller: self,
                                                  passkeyRequest: passketReq) { status, response, error in
            debugPrint("Prasanna: PasskeyViewController authenticatePasskey", #function, status, response, error?.message)
        }
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
