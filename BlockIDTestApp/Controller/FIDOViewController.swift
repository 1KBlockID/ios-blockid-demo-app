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
        guard let registeredUser = UserDefaults.standard.string(forKey: AppConsant.fidoUserName) else {
            return
        }
        self.txtFieldUsername.text = registeredUser
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        guard let username = self.txtFieldUsername.text,
              !username.isEmpty && !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let alert = UIAlertController(title: "Error", message: "User name can't be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
               // do nothing
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.registerFIDO2Key(userName: username,
                                                  tenantDNS: AppConsant.defaultTenant.dns!,
                                                  communityName: AppConsant.defaultTenant.community!)
        { status, error in
            self.view.hideToastActivity()
            if status {
                    let alert = UIAlertController(title: "Success", message: "You have successfully registered", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                       // do nothing
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                UserDefaults.standard.set(username, forKey: AppConsant.fidoUserName)
            } else {
                guard let msg = error?.message, let code = error?.code else {
                    return
                }
                let alert = UIAlertController(title: "Error", message: "\(msg), \(code)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                   // do nothing
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
       
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {
        guard let username = self.txtFieldUsername.text,
              !username.isEmpty && !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let alert = UIAlertController(title: "Error", message: "User name can't be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
               // do nothing
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.view.makeToastActivity(.center)
        
        BlockIDSDK.sharedInstance.authenticateFIDO2Key(userName: username,
                                                  tenantDNS: AppConsant.defaultTenant.dns!,
                                                  communityName: AppConsant.defaultTenant.community!)
        { status, error in
                self.view.hideToastActivity()
                if status {
                    let alert = UIAlertController(title: "Success", message: "You have successfully authenticated", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        // do nothing
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }  else {
                    guard let msg = error?.message, let code = error?.code else {
                        return
                    }
                    let alert = UIAlertController(title: "Error", message: "\(msg), \(code)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                       // do nothing
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
