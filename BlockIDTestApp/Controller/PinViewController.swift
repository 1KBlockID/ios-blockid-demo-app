//
//  PinViewController.swift
//  BlockIDTestApp
//
//  Created by vaidehi hindlekar on 06/05/21.
//

import Foundation
import BlockIDSDK
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
    
    private let customBar: AccessoryView = AccessoryView()
    private var isIncorrectPin = false
    public var pinActivity = PinActivity.isEnrolling
    private var _firstPin: String!
    
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
        _viewPin.keyboardType = .numberPad
        _viewPin.fontSize = 20
        customBar.onNextCallback = {(sender) -> Void in
            self.onNext()
        }
        customBar.setBtnTitle("Next")
        _viewPin.inputAccessoryView = customBar.addBar(CGRect(x:0, y:0, width:100, height:40))
        _viewPin.delegate = self
    }

    @objc private func onNext() {
        if _viewPin.text == nil || _viewPin.text!.count < _viewPin.characterLimit {
            return // no-op
        }
        
        if _firstPin == nil {
            
            //------------------------First Pin Entered---------------
            customBar.setBtnTitle("Done")
            _firstPin = _viewPin.text!
            _viewPin.text = ""
            _enterPinTitle.text = "Confirm new PIN"
            return
        }
        
        //on second screen
        if _viewPin.text == _firstPin {
            if pinActivity == .isRemoving {
                removePin(pin: _firstPin)
            }
            else if pinActivity == .isEnrolling {
                onSuccess()
            }
            else if pinActivity == .isLogin {
                showEnrollmentView()
            }
            
        } else {
            onPinMismatch()
        }
    }
    
    private func removePin(pin: String) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.removePin(pin: pin) { [weak self] status, error in
            self?.view.hideToastActivity()
            if status {
                self?.view.makeToast("Pin enrolled successfully.", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
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
        BlockIDSDK.sharedInstance.setPin(pin: _viewPin.text!) {
            (status, error) in
            self.view.hideToastActivity()
            if !status {
                var title: String? = nil
                var msg: String? = nil
                if error?.code == NSURLErrorNotConnectedToInternet {
                    title = ErrorConfig.noInternet.title
                    msg = ErrorConfig.noInternet.message
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

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.goBack()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

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
