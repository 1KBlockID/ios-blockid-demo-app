//
//  UserOptionsViewController.swift
//  BlockIDTestApp
//
//  Created by Kuldeep Choudhary on 06/12/22.
//

import Foundation
import UIKit
import BlockIDSDK
import Toast_Swift

class UserOptionsViewController: UIViewController {
    
    var currentUser: BIDLinkedAccount!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLbl.text = "Welcome \(currentUser.userId)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Button Actions
    
    @IBAction func registerPlatformKey(_ sender: UIButton) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.registerFIDO2Key(controller: self, linkedAccount: currentUser, type: .PLATFORM) { status, err in
            self.view.hideToastActivity()
            if !status {
                guard let err = err else { return }
                self.showAlertView(title: "Error", message: err.message)
                return
            }
            self.view.makeToast("Platform key registered successfully", duration: 3.0, position: .center) {
                _ in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func registerExtKey(_ sender: UIButton) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.registerFIDO2Key(controller: self, linkedAccount: currentUser, type: .CROSS_PLATFORM) { status, err in
            self.view.hideToastActivity()
            if !status {
                guard let err = err else { return }
                self.showAlertView(title: "Error", message: err.message)
                return
            }
            self.view.makeToast("External key registered successfully", duration: 3.0, position: .center) {
                _ in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func authenticatePlatformKey(_ sender: UIButton) {
    }
    @IBAction func authenticateExtKey(_ sender: UIButton) {
    }
    
    @IBAction func removeAccount(_ sender: UIButton) {
        let alert = UIAlertController(title: "Warning!", message: "Do you want to remove the user?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.unlinkUser(linkedAccount: self.currentUser)
        }))
    
        self.present(alert, animated: true)

    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    private func unlinkUser(linkedAccount: BIDLinkedAccount) {
        
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.unLinkAccount(bidLinkedAccount: linkedAccount,
                                                deviceToken: nil) { [weak self] (success, error) in
            guard let weakSelf = self else {return}
            weakSelf.view.hideToastActivity()
            if success {
                weakSelf.view.makeToast("Your account is removed.", duration: 3.0, position: .center) {
                    _ in
                    weakSelf.navigationController?.popViewController(animated: true)
                }
            } else {
                // failure
                if error?.code == NSURLErrorNotConnectedToInternet ||
                    error?.code == CustomErrors.Network.OFFLINE.code {
                    let localizedMessage = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
                    self?.showAlertView(title: "Error", message: localizedMessage)
                    weakSelf.view.makeToast(localizedMessage,
                                            duration: 3.0,
                                            position: .center,
                                            title: ErrorConfig.noInternet.title,
                                            completion: nil)
                } else {
                    weakSelf.view.makeToast(error?.message,
                                            duration: 3.0,
                                            position: .center,
                                            title: ErrorConfig.error.title,
                                            completion: nil)
                }
            }
        }
    }
}
