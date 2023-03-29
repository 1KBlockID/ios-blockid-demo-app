//
//  FIDOKeyManagementController.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 20/03/23.
//

import UIKit
import BlockID

class FIDOKeyManagementController: UIViewController {

    // MARK: - View life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions -
    @IBAction func setPIN(_ sender: UIButton) {
        // valdidate key pin...
        setPINInputAlert{ newPin, confirmPin in
            guard let newPin = newPin,
                  let confirmPin = confirmPin,
                    self.validateSetPin(newPin: newPin,
                                        confirmPin: confirmPin) else {
                return
            }
            // set key pin...
            BlockIDSDK.sharedInstance.setFido2PIN(newPin: newPin) { status, error in
                if !status {
                    guard let err = error else { return }
                    DispatchQueue.main.async {
                        self.showAlertView(title: "Error",
                                           message: "\(err.message) (\(err.code)).")
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Success",
                                                      message: "You have successfully set the PIN", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK",
                                                      style: .default, handler: { action in
                            // do nothing
                            
                        }))
                        self.present(alert,
                                     animated: true,
                                     completion: nil)
                    }
                }
            }
        }
        
    }
    
    @IBAction func changePIN(_ sender: UIButton) {
        // valdidate key pin...
        changePINInputAlert{ oldPin, newPin in
            guard let oldPin = oldPin,
                  let newPin = newPin else {
                return
            }
            // change key pin...
            BlockIDSDK.sharedInstance.changeFido2PIN(oldPin: oldPin,
                                                     newPin: newPin) { status, error in
                if !status {
                    guard let err = error else { return }
                    DispatchQueue.main.async {
                        self.showAlertView(title: "Error",
                                           message: "\(err.message) (\(err.code)).")
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Success",
                                                      message: "You have successfully changed the PIN", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK",
                                                      style: .default, handler: { action in
                            // do nothing
                        }))
                        self.present(alert,
                                     animated: true,
                                     completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func resetFIDO(_ sender: UIButton) {
        // Reset key pin...
        BlockIDSDK.sharedInstance.resetFido2 { status, error in
            if !status {
                guard let err = error else { return }
                DispatchQueue.main.async {
                    self.showAlertView(title: "Error",
                                       message: "\(err.message) (\(err.code)).")
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success",
                                                  message: "You have successfully reset FIDO2",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: .default, handler: { action in
                        // do nothing
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /// Set Pin Code
    ///
    /// This will handle the pin if present on used external key
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
    
    /// Change Pin Code
    ///
    /// This will handle the pin if present on used external key
    private func changePINInputAlert(completion: @escaping (String?, String?) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(changePinInputCompletion: { oldPin, newPin, confirmPin in
                guard let oldPin = oldPin,
                      let newPin = newPin,
                      let confirmPin = confirmPin,
                      self.validateChangePin(oldPin: oldPin,
                                             newPin: newPin,
                                             confirmPin: confirmPin)  else {
                    completion(nil, nil)
                    return
                }
                completion(oldPin, newPin)
            })
            self.present(alert, animated: true)
        }
    }
    
    
    /// handle the pin validation to set...
    private func validateSetPin(newPin: String,
                                confirmPin: String) -> Bool {
        
        if newPin.isEmpty || confirmPin.isEmpty {
            // show error
            showAlertView(title: "Error", message: "PIN can not be empty")
            return false
        }
        
        if newPin.count < 4 || confirmPin.count < 4 {
            // show error
            self.showAlertView(title: "Error", message: "PIN can not be less than 4 digits")
            return false
        }
        
        if newPin != confirmPin {
            showAlertView(title: "Error", message: "PIN does not match")
            return false
        }

        return true
    }
    
    /// handle the pin validation to change...
    private func validateChangePin(oldPin: String,
                                   newPin: String,
                                   confirmPin: String) -> Bool {
        
        if oldPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty {
            // show error
            showAlertView(title: "Error",
                          message: "PIN can not be empty")
            return false
        }
        
        if oldPin.count < 4 || newPin.count < 4 || confirmPin.count < 4 {
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

}

// MARK: - Extensions - 
extension UIAlertController {
    
    convenience init(setPinInputCompletion:  @escaping (String?, String?) -> Void) {
        
        self.init(title: "Set PIN",
                  message: "Enter the new PIN",
                  preferredStyle: UIAlertController.Style.alert)
        
        addTextField { (textField) in
            textField.placeholder = "New PIN"
            textField.isSecureTextEntry = true
        }
        
        addTextField { (textField) in
            textField.placeholder = "Confirm PIN"
            textField.isSecureTextEntry = true
        }
        
        addAction(UIAlertAction(title: "Done",
                                style: .default, handler: { (action) in
            let newPin = self.textFields![0].text
            let confirmPin = self.textFields![1].text
            setPinInputCompletion(newPin, confirmPin)
        }))
        addAction(UIAlertAction(title: "Cancel",
                                style: .cancel, handler: { (action) in
            setPinInputCompletion(nil, nil)
        }))
        
    }
    
    convenience init(changePinInputCompletion:  @escaping (String?, String?, String?) -> Void) {
        
        self.init(title: "Set PIN",
                  message: "Enter the new PIN",
                  preferredStyle: UIAlertController.Style.alert)
        
        self.init(title: "Change PIN",
                  message: "Enter the key PIN",
                  preferredStyle: UIAlertController.Style.alert)
        addTextField { (textField) in
            textField.placeholder = "current PIN"
            textField.isSecureTextEntry = true
        }
        
        addTextField { (textField) in
            textField.placeholder = "New PIN"
            textField.isSecureTextEntry = true
        }
        
        addTextField { (textField) in
            textField.placeholder = "Confirm PIN"
            textField.isSecureTextEntry = true
        }
        
        addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            let oldPin = self.textFields![0].text
            let newPin = self.textFields![1].text
            let confirmPin = self.textFields![2].text
            changePinInputCompletion(oldPin, newPin, confirmPin)
        }))
        addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            changePinInputCompletion(nil, nil, nil)
        }))
    }
    
}
