//
//  PinViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import BlockID
import Toast_Swift

public enum PinActivity {
    case isEnrolling
    case isRemoving
    case isLogin
}
  
class PinViewController: UIViewController {
    
    @IBOutlet private weak var _viewPin: PinCodeTextField!
    @IBOutlet weak var lblIncorrectPin: UILabel!
    @IBOutlet weak var _enterPinTitle: UILabel!
    
    private var isIncorrectPin = false
    private var _firstPin: String!
    
    public var pinActivity = PinActivity.isEnrolling
    var onFinishCallback: ((_ status: Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinViewUpdates()
        lblIncorrectPin.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _viewPin.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _viewPin.resignFirstResponder()
    }
    
    private func pinViewUpdates() {
        if pinActivity == .isEnrolling {
            _enterPinTitle.text = "Enter new PIN"
        }
        else {
            _enterPinTitle.text = "Confirm PIN"
        }
        _viewPin.keyboardType = .numberPad
        _viewPin.fontSize = 20
        _viewPin.delegate = self
    }

    @objc private func onNext() {
        if _viewPin.text == nil || _viewPin.text!.count < _viewPin.characterLimit {
            return // no-op
        }
        
        //on second screen
        if pinActivity == .isLogin || pinActivity == .isRemoving {
             if BlockIDSDK.sharedInstance.verifyPin(pin:_viewPin.text ?? "") {
                if pinActivity == .isLogin {
                    if let onFinishCallback = self.onFinishCallback {
                        onFinishCallback(true)
                        self.goBack()
                        return 
                    }
                    self.showEnrollmentView()
                }
                else if  pinActivity == .isRemoving {
                    removePin(pin:_viewPin.text ?? "")
                }
                return
             }
             else {
                self.view.makeToast("Pin mismatched", duration: 3.0, position: .center, title: "Error", completion: {_ in
                   
                })
                return
             }
        }
    
        
        if _firstPin == nil {
            
            //------------------------First Pin Entered---------------
            _firstPin = _viewPin.text!
            _viewPin.text = ""
            if pinActivity == .isEnrolling {
                _enterPinTitle.text = "Confirm new PIN"
            }
            else {
                _enterPinTitle.text = "Confirm PIN"
            }
            return
        }
        
        //on second screen
        if _viewPin.text == _firstPin {
            onSuccess()
        } else {
            onPinMismatch()
        }
    }
    
    private func removePin(pin: String) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.removePin(pin: pin) { [weak self] status, error in
            self?.view.hideToastActivity()
            if status {
                self?.view.makeToast("Pin unenrolled successfully", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
                    self?.goBack()
                })
                return
            }
        }
    }
    
    private func onPinMismatch() {
        _viewPin.textColorName = "misc4"
        _viewPin.underLineColorName = "misc4"
        _viewPin.refreshView()
        lblIncorrectPin.isHidden = false
    }
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    private func onSuccess() {
        //-----------------Registration successful---------
        self.view.makeToastActivity(.center)
        _viewPin.resignFirstResponder()
        BlockIDSDK.sharedInstance.setPin(pin: _viewPin.text!, proofedBy: "blockid") {
            (status, error) in
            self.view.hideToastActivity()
            if !status {
                var title: String? = nil
                var msg: String? = nil
                if error?.code == NSURLErrorNotConnectedToInternet || error?.code == CustomErrors.Network.OFFLINE.code {
                    title = ErrorConfig.noInternet.title
                    msg = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
                }
                else if (error != nil && error?.code == CustomErrors.kUnauthorizedAccess.code) {
                    self.showAppLogin()
                }
                else {
                    title = ErrorConfig.error.title
                    msg = error!.message.isEmpty  ? "PIN registration failed" : error!.message
                }

                let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                    self.goBack()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

                self.present(alert, animated: true)
                return
            }
            if self.pinActivity == .isEnrolling {
                self.view.makeToast("Pin enrolled successfully", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
                    self.goBack()
                })
                return
            }
            self.goBack()
        }
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        
        if pinActivity == .isEnrolling {
            let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to cancel the registration process?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.goBack()
            }))
            
            self.present(alert, animated: true)
            return
            
        }
        self.goBack()
    }
    
    private func reinstatePinView() {
        _viewPin.refreshView()
        isIncorrectPin = false
    }
 
    
}

extension PinViewController : PinCodeTextFieldDelegate {
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        if isIncorrectPin {
            reinstatePinView()
        }
        if textField.characterLimit == textField.text?.count {
            onNext()
        }
    }
}
