//
//  FIDOViewController.swift
//  BlockIDTestApp
//
//  Created by Kuldeep Choudhary on 23/03/22.
//

import Foundation
import UIKit
import BlockID

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
    
    /// Handle Pin Code
    ///
    /// This will handle the pin if present on external key used
    private func showPINInputAlert(completion: @escaping (_ pin: String?) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(pinInputCompletion: { pin in
                guard let pin = pin else {
                    completion(nil)
                    return
                }
                completion(pin)
            })
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func registerPlatformKey(_ sender: UIButton) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.registerFIDO2Key(controller: self,
                                                   userName: self.txtFieldUsername.text!,
                                                   tenantDNS: Tenant.defaultTenant.dns!,
                                                   communityName: Tenant.defaultTenant.community!,
                                                   type: .PLATFORM) { status, err in
            self.view.hideToastActivity()
            if !status {
                guard let err = err else { return }
                self.showAlertView(title: "Error", message: "\(err.message) (\(err.code)).")
                return
            }
            UserDefaults.standard.set(self.txtFieldUsername.text,
                                      forKey: AppConsant.fidoUserName)
            self.showAlertView(title: "",
                               message: "Platform key registered successfully.")
        }
    }
    
    @IBAction func registerExternalKey(_ sender: UIButton) {
            self.view.makeToastActivity(.center)
            BlockIDSDK.sharedInstance.registerFIDO2Key(controller: self,
                                                       userName: self.txtFieldUsername.text!,
                                                       tenantDNS: Tenant.defaultTenant.dns!,
                                                       communityName: Tenant.defaultTenant.community!,
                                                       type: .CROSS_PLATFORM) { status, err in
                self.view.hideToastActivity()
                if !status {
                    guard let err = err else { return }
                    self.showAlertView(title: "Error",
                                       message: "\(err.message) (\(err.code)).")
                    return
                }
                UserDefaults.standard.set(self.txtFieldUsername.text,
                                          forKey: AppConsant.fidoUserName)
                self.showAlertView(title: "",
                                   message: "Security key registered successfully.")
            }
    }
    
    @IBAction func registerExternalKeyWithPin(_ sender: UIButton) {
        showPINInputAlert { pin in
            guard let verifiedPin = pin else {
                return
            }
            self.registerFIDO2ExternelKeyWithPin(pin: verifiedPin)
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
                self.showAlertView(title: "Error",
                                   message: "\(err.message) (\(err.code)).")
                return
            }
            UserDefaults.standard.set(self.txtFieldUsername.text,
                                      forKey: AppConsant.fidoUserName)
            self.showAlertView(title: "",
                               message: "Platform key authenticated successfully.")
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
                    self.showAlertView(title: "Error", message: "\(err.message) (\(err.code)).")
                    return
                }
                UserDefaults.standard.set(self.txtFieldUsername.text,
                                          forKey: AppConsant.fidoUserName)
                self.showAlertView(title: "",
                                   message: "Security key is authenticated successfully.")
            }
    }
    
    @IBAction func authenticateExternalKeyWithPin(_ sender: UIButton) {
        showPINInputAlert { pin in
            guard let verifiedPin = pin else {
                return
            }
            self.view.makeToastActivity(.center)
            BlockIDSDK.sharedInstance.authenticateFIDO2Key(controller: self,
                                                           userName: self.txtFieldUsername.text!,
                                                           tenantDNS: Tenant.defaultTenant.dns!,
                                                           communityName: Tenant.defaultTenant.community!,
                                                           type: .CROSS_PLATFORM,
                                                           pin: verifiedPin) { status, error in
                self.view.hideToastActivity()
                if !status {
                    guard let err = error else { return }
                    self.showAlertView(title: "Error", message: "\(err.message) (\(err.code)).")
                    return
                }
                UserDefaults.standard.set(self.txtFieldUsername.text,
                                          forKey: AppConsant.fidoUserName)
                self.showAlertView(title: "",
                                   message: "Security key is authenticated successfully.")
            }
        }
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        
        self.view.makeToastActivity(.center)
        // fileName parameter is optional
        // provide filename if customized html is required
        BlockIDSDK.sharedInstance.registerFIDO2Key(userName: self.txtFieldUsername.text!,
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
                UserDefaults.standard.set(self.txtFieldUsername.text!, forKey: AppConsant.fidoUserName)
            } else {
                guard let msg = error?.message, let code = error?.code else {
                    return
                }
                let alert = UIAlertController(title: "Error", message: "\(msg) (\(code)).", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                   // do nothing
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
       
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {

        self.view.makeToastActivity(.center)
        // fileName parameter is optional
        // provide filename if customized html is required
        BlockIDSDK.sharedInstance.authenticateFIDO2Key(userName: self.txtFieldUsername.text!,
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
                    let alert = UIAlertController(title: "Error", message: "\(msg) (\(code)).", preferredStyle: .alert)
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
    
    private func registerFIDO2ExternelKeyWithPin(pin: String,
                                                 setPin: Bool = false) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.registerFIDO2Key(controller: self,
                                                   userName: self.txtFieldUsername.text!,
                                                   tenantDNS: Tenant.defaultTenant.dns!,
                                                   communityName: Tenant.defaultTenant.community!,
                                                   type: .CROSS_PLATFORM,
                                                   pin: pin,
                                                   setPin: setPin) { status, err in
            self.view.hideToastActivity()
            if !status {
                guard let err = err else { return }
                if err.message == "No PIN has been set." {
                    self.handleError(error: err)
                } else {
                    self.showAlertView(title: "Error",
                                       message: "\(err.message) (\(err.code)).")
                }
            } else {
                UserDefaults.standard.set(self.txtFieldUsername.text,
                                          forKey: AppConsant.fidoUserName)
                self.showAlertView(title: "",
                                   message: "Security key registered successfully.")
            }
        }
    }
    
    private func handleError(error: ErrorResponse) {
        let alert = UIAlertController(title: "Error",
                                      message: "\(error.message) (\(error.code)).",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title:
                                        "Cancel",
                                      style: .default, handler: nil))
        alert.addAction(UIAlertAction(title:
                                        "Set PIN",
                                      style: .default, handler: {_ in
            self.setPINInputAlert { newPin, confirmPin in
                guard let newPin = newPin,
                      let confirmPin = confirmPin,
                      self.validateSetPin(newPin: newPin,
                                          confirmPin: confirmPin) else {
                    return
                }
                self.registerFIDO2ExternelKeyWithPin(pin: confirmPin,
                                                     setPin: true)
            }
        }))
        self.present(alert, animated: true)
    }
    
    private func validateSetPin(newPin: String,
                                confirmPin: String) -> Bool {
        
        if newPin.isEmpty || confirmPin.isEmpty {
            // show error
            showAlertView(title: "Error",
                          message: "PIN can not be empty")
            return false
        }
        
        if newPin.count < 4 || confirmPin.count < 4 {
            // show error
            self.showAlertView(title: "Error",
                               message: "PIN can not be less than 4 digits")
            return false
        }
        
        if newPin != confirmPin {
            showAlertView(title: "Error",
                          message: "PIN does not match")
            return false
        }

        return true
    }
    
    /// Handle Pin Code
    ///
    /// This will handle the pin if present on external key used
    private func setPINInputAlert(completion: @escaping (_ newPin: String?,
                                                         _ confirmPin: String?) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(setPinInputCompletion: { newPin, confirmPin in
                guard let newPin = newPin,
                      let confirmPin = confirmPin else {
                    completion(nil, nil)
                    return
                }
                completion(newPin, confirmPin)
            })
            self.present(alert, animated: true)
            
        }
    }
}

extension UIAlertController {
    convenience init(pinInputCompletion:  @escaping (String?) -> Void) {
        self.init(title: "PIN verification required",
                  message: "Enter the key PIN",
                  preferredStyle: UIAlertController.Style.alert)
        addTextField { (textField) in
            textField.placeholder = "PIN"
            textField.isSecureTextEntry = true
        }
        addAction(UIAlertAction(title: "Verify",
                                style: .default,
                                handler: { (action) in
            let pin = self.textFields![0].text
            pinInputCompletion(pin)
        }))
        addAction(UIAlertAction(title: "Cancel",
                                style: .cancel,
                                handler: { (action) in
            pinInputCompletion(nil)
        }))
    }
}
