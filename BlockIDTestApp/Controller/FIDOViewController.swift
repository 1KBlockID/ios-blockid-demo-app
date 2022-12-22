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
    
    // MARK: - IBOutlets -
    @IBOutlet weak var txtFieldUsername: UITextField!
    
    // MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()   
        self.txtFieldUsername.delegate = self
        guard let registeredUser = UserDefaults.standard.string(forKey: AppConsant.fidoUserName) else {
            return
        }
        self.txtFieldUsername.text = registeredUser
    }
    
    // MARK: - IBActions -
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func registerPlatformKey(_ sender: UIButton) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.registerFIDO2Key(controller: self,
                                                   userName: self.txtFieldUsername.text,
                                                   tenantDNS: Tenant.defaultTenant.dns!,
                                                   communityName: Tenant.defaultTenant.community!,
                                                   type: .PLATFORM) { status, err in
            self.view.hideToastActivity()
            if !status {
                guard let err = err else { return }
                self.showAlertView(title: "Error", message: err.message)
                return
            }
            UserDefaults.standard.set(self.txtFieldUsername.text,
                                      forKey: AppConsant.fidoUserName)
            self.view.makeToast("Platform key registered successfully", duration: 3.0, position: .center) {
                _ in
                //
            }
        }
        
    }
    
    @IBAction func registerExternalKey(_ sender: UIButton) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.registerFIDO2Key(controller: self,
                                                   userName: self.txtFieldUsername.text,
                                                   tenantDNS: Tenant.defaultTenant.dns!,
                                                   communityName: Tenant.defaultTenant.community!,
                                                   type: .CROSS_PLATFORM) { status, err in
            self.view.hideToastActivity()
            if !status {
                guard let err = err else { return }
                self.showAlertView(title: "Error", message: err.message)
                return
            }
            UserDefaults.standard.set(self.txtFieldUsername.text,
                                      forKey: AppConsant.fidoUserName)
            self.view.makeToast("Security key registered successfully", duration: 3.0, position: .center) {
                _ in
                //
            }
        }
    }
    
    @IBAction func authenticatePlatformKey(_ sender: UIButton) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.authenticateFIDO2Key(controller: self,
                                                       userName: self.txtFieldUsername.text!,
                                                       tenantDNS: Tenant.defaultTenant.dns!,
                                                       communityName: Tenant.defaultTenant.community!,
                                                       type: .PLATFORM) { status, error in
            self.view.hideToastActivity()
            if !status {
                guard let err = error else { return }
                self.showAlertView(title: "Error", message: "\(err.message) (\(err.code).")
                return
            }
            UserDefaults.standard.set(self.txtFieldUsername.text,
                                      forKey: AppConsant.fidoUserName)
            self.view.makeToast("Platform key authenticated successfully",
                                duration: 3.0,
                                position: .center) {
                _ in
                //
            }
        }
    }
    
    @IBAction func authenticateExternalKey(_ sender: UIButton) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.authenticateFIDO2Key(controller: self,
                                                       userName: self.txtFieldUsername.text!,
                                                       tenantDNS: Tenant.defaultTenant.dns!,
                                                       communityName: Tenant.defaultTenant.community!,
                                                       type: .CROSS_PLATFORM) { status, error in
            self.view.hideToastActivity()
            if !status {
                guard let err = error else { return }
                self.showAlertView(title: "Error", message: err.message)
                return
            }
            UserDefaults.standard.set(self.txtFieldUsername.text,
                                      forKey: AppConsant.fidoUserName)
            self.view.makeToast("Security key is authenticated successfully.", duration: 3.0, position: .center) {
                _ in
                //
            }
        }
        
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
        
        // fileName parameter is optional
        // provide filename if customized html is required
        BlockIDSDK.sharedInstance.registerFIDO2Key(userName: username,
                                                   tenantDNS: Tenant.defaultTenant.dns!,
                                                   communityName: Tenant.defaultTenant.community!,
                                                   fileName: "fido3.html")
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
        
        // fileName parameter is optional
        // provide filename if customized html is required
        BlockIDSDK.sharedInstance.authenticateFIDO2Key(userName: username,
                                                       tenantDNS: Tenant.defaultTenant.dns!,
                                                       communityName: Tenant.defaultTenant.community!,
                                                       fileName: "fido3.html")
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
