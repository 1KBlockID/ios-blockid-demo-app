//
//  FIDOViewController.swift
//  BlockIDTestApp
//
//  Created by Kuldeep Choudhary on 23/03/22.
//

import Foundation
import UIKit
import BlockIDSDK

class FIDOViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtFieldUsername: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtFieldUsername.delegate = self
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    
    
    @IBAction func registerTapped(_ sender: Any) {
        if let username = self.txtFieldUsername.text {
            BlockIDSDK.sharedInstance.registerFIDOKey(userName: username,
                                                      tenantDNS: Tenant.defaultTenant.dns!,
                                                      communityName: Tenant.defaultTenant.community!)
            { status, error in
                if status {
                    let alert = UIAlertController(title: "Success", message: "You have successfully registered", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                       // self.navigationController?.popViewController(animated: true)
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {
        print("34\n")
        if let username = self.txtFieldUsername.text {
            print("35\n")
            BlockIDSDK.sharedInstance.authenticateFIDOKey(userName: username,
                                                      tenantDNS: Tenant.defaultTenant.dns!,
                                                      communityName: Tenant.defaultTenant.community!)
            { status, error in
                
                if status {
                    let alert = UIAlertController(title: "Success", message: "You have successfully authenticated", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.navigationController?.popViewController(animated: true)
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
