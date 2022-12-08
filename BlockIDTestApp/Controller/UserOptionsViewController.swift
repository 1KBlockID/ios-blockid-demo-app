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
    fileprivate var fidoType: FIDO2KeyType!
    
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
        fidoType = .PLATFORM
        self.showQRCodeScanner()
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
    
    private func showQRCodeScanner() {
        let scanQRVC = self.storyboard?.instantiateViewController(withIdentifier: "ScanQRViewController") as! ScanQRViewController
        scanQRVC.delegate = self
        self.present(scanQRVC, animated: true)
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
    
    func authenticateUser(fidoType: FIDO2KeyType, sessionUrl: String, dataModel: AuthenticationPayloadV2?) {
        
        BlockIDSDK.sharedInstance.authenticateWithFIDO2Key(type: fidoType,
                                                           controller: self,
                                                           sessionId: dataModel?.sessionId,
                                                           sessionURL: sessionUrl,
                                                           creds: "",
                                                           scopes: dataModel?.scopes,
                                                           lat: 0.0,
                                                           lon: 0.0,
                                                           origin: dataModel?.origin,
                                                           metaData: dataModel?.metadata) {(status, _, error) in
            if status {
                //if success
                self?.view.makeToast("You have successfully authenticated to Log In", duration: 3.0, position: .center, title: "Success", completion: {_ in
                    return
                })

            }
        }
    }
}

extension UserOptionsViewController: ScanQRViewDelegate {
    func scannedData(data: String) {
        processQRData(data)
    }
    
    private func processQRData(_ data: String) {
        
        // uwl 2.0
        if data.hasPrefix("https://") && data.contains("/sessions") {
            handleUWL2(data: data)
            return
        }
        
        // uwl 1.0
        //decode the base64 payload data
        guard let decodedData = Data(base64Encoded: data) else {
            self.inValidQRCode()
            return
        }
        
        let decodedString = String(data: decodedData, encoding: .utf8)!
        let qrModel = CommonFunctions.jsonStringToObject(json: decodedString) as AuthenticationPayloadV1?
        
        // 1. Scopes converted to lowercase
        qrModel?.scopes = qrModel?.scopes?.lowercased()
        
        // 2. If scopes has "windows", replace it by "scep_creds"
        qrModel?.scopes = qrModel?.scopes?.replacingOccurrences(of: "windows", with: "scep_creds")
        
        
    }

    private func handleUWL2(data: String) {
        
            let arrSplitStrings = data.components(separatedBy: "/session/")
            let url = arrSplitStrings.first ?? ""
            if BlockIDSDK.sharedInstance.isTrustedSessionSources(sessionUrl: url) {

                GetSessionData.sharedInstance.getSessionData(url: data) { [self] response, message, isSuccess in
                    
                    if isSuccess {
                        let authQRUWL2 = CommonFunctions.jsonStringToObject(json: response ?? "") as AuthenticationPayloadV2?
                        // authenticate user
                        self.authenticateUser(fidoType: self.fidoType, sessionUrl: data, dataModel: authQRUWL2)
                    } else {
                        // Show toast
                        self.view.makeToast(message, duration: 3.0, position: .center, title: "Error", completion: {_ in
                            return
                        })
                    }
                }
            } else {
                // Show toast
                self.view.makeToast("Suspicious QR Code", duration: 3.0, position: .center, title: "Error", completion: {_ in
                    return
                })
            }
    }
    
    private func inValidQRCode() {
        self.showAlertView(title: "Invalid Code", message: "Unsupported QR code detected.")
    }
}
