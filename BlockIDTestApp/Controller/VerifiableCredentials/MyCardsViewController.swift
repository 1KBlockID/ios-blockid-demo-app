//
//  MyCardsViewController.swift
//  BlockIDTestApp
//
//  Created by Sushil Tiwari on 29/09/22.
//

import UIKit
import PassKit
import BlockIDSDK

// define type of document using which the
// verifiable credentials will be created
public enum VCType {
    case document
    case payload
}

class MyCardsViewController: UIViewController {
    
    // enrolled drivers licenses
    private var registeredDocument: [String: Any]?
    
    // define list of pass
    let passes = ["BoardingPass", "Event", "Generic", "StoreCard", "Coupon"]
    
    // MARK: - View Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // get enrolled drivers license
        self.registeredDocument = self.getRegisteredDocument(type: RegisterDocType.DL.rawValue)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set title
        self.title = "My Cards"
        
        // show navigation bar
        self.showNavigationBar(yorn: false)
        
        // add button items
        self.setupNavigationBarButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // hide navigation bar
        self.showNavigationBar(yorn: true)
    }
    
    // MARK: - IBActions -
    @IBAction func addToAppleWallet(sender: Any) {
        self.addCardToAppleWallet()
    }
}

// MARK: - Extension: Private Methods -
extension MyCardsViewController {
    private func getRegisteredDocument(type: RegisterDocType.RawValue) -> [String: Any]? {
        var regDocument: [String: Any]?
        if let enrolledDoc = BIDDocumentProvider.shared.getUserDocument(id: nil,
                                                                        type: type,
                                                                        category: RegisterDocCategory.Identity_Document.rawValue) {
            let data = Data(enrolledDoc.utf8)
            do {
                if let document = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    regDocument = document.first
                }
            } catch {
                debugPrint("some exception when converting JSON to object",error)
            }
        }
        
        return regDocument
    }
    
    private func showNavigationBar(yorn: Bool) -> Void {
        self.navigationController?.setNavigationBarHidden(yorn,
                                                          animated: false)
    }
    
    private func setupNavigationBarButtons() -> Void {
        
        // create right bar button item
        let rightButton = UIBarButtonItem(barButtonSystemItem: .add,
                                          target: self,
                                          action: #selector(self.showOptionsSheet))
        
        // set right bar button item
        self.navigationItem.setRightBarButton(rightButton,
                                              animated: true)
    }
    
    @objc private func showOptionsSheet() -> Void {
        // Create An UIAlertController with Action Sheet
        let optionsController = UIAlertController(title: nil,
                                                  message: "Choose Option",
                                                  preferredStyle: .actionSheet)
        
        // Create UIAlertAction for UIAlertController
        // Add ID
        let addIDAction = UIAlertAction(title: "Add ID",
                                        style: .default,
                                        handler: { (alert: UIAlertAction!) -> Void in
            self.intiateAddIDCardFlow()
        })
        
        // Scan QR
        let scanQRAction = UIAlertAction(title: "Scan QR",
                                         style: .default,
                                         handler: { (alert: UIAlertAction!) -> Void in
            print("Scan QR")
        })
        
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: { (alert: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        // Add UIAlertAction in UIAlertController
        optionsController.addAction(addIDAction)
        optionsController.addAction(scanQRAction)
        optionsController.addAction(cancelAction)
        
        // Present UIAlertController with Action Sheet
        self.present(optionsController,
                     animated: true,
                     completion: nil)
    }
    
    private func addCardToAppleWallet() -> Void {
        // reading pass file data from local file;
        // the data should come from API
        if let path = Bundle.main.url(forResource: passes.randomElement(),
                                      withExtension: "pkpass") {
            do {
                let passData = try Data(contentsOf: path)
                
                do {
                    // Create Pass Object
                    let pass = try PKPass(data: passData)
                    
                    // Access Pass Library
                    let passLibrary = PKPassLibrary()
                    
                    // check is pass exists
                    if (passLibrary.containsPass(pass)) {
                        let alert = UIAlertController(title: "Pass Exists",
                                                      message: "Pass is already in Passbook.",
                                                      preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK",
                                                      style: .default,
                                                      handler: nil))
                        
                        self.present(alert, animated: true)
                    } else {
                        if let passVC = PKAddPassesViewController(pass: pass) {
                            passVC.delegate = self
                            self.present(passVC, animated: true)
                        }
                    }
                } catch {
                    let alert = UIAlertController(title: "Invalid Pass",
                                                  message: error.localizedDescription + ".",
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: .default,
                                                  handler: nil))
                    
                    self.present(alert, animated: true)
                    
                }
            } catch {
                let alert = UIAlertController(title: "Error",
                                              message: "Unable to ready pass file.",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK",
                                              style: .default,
                                              handler: nil))
                
                self.present(alert, animated: true)
            }
        } else {
            let alert = UIAlertController(title: "Error",
                                          message: "Pass file not found.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    private func intiateAddIDCardFlow() -> Void {
        // check is drivers license document is enrolled
        // else show an error message
        if self.registeredDocument != nil {
            // dl document is registered
            // get verifiable credential for it
            ServiceDirectory.sharedInstance.getServiceDirectoryDetails(forTenant: AppConsant.defaultTenant) { (result, error) in
                if error == nil {
                    if let result = result {
                        if let code = result["code"] as? Int,
                           let message = result["message"] as? String {
                            // show error message
                            let alert = UIAlertController(title: "Oh no ...",
                                                          message: message + "\(code).",
                                                          preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK",
                                                          style: .default,
                                                          handler: nil))
                            
                            self.present(alert, animated: true)
                            return
                        }
                        
                        if let vcsURL = result["vcs"] as? String {
                            // service directory details available
                            // check for 'vcs' url and proceed to
                            // request verifiable credentials for enrolled dl
                            self.createVerifiableCredentials(from: VCType.document,
                                                             withURL: vcsURL)
                        } else {
                            // 'vcs' url not found
                            // show error message
                            let alert = UIAlertController(title: "Oh no ...",
                                                          message: "Verifiable credentials service is not available for the requested tenant. Please contact support team.",
                                                          preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK",
                                                          style: .default,
                                                          handler: nil))
                            
                            self.present(alert, animated: true)
                        }
                    }
                } else {
                    // show error message
                    let alert = UIAlertController(title: "Oh no ...",
                                                  message: error?.localizedDescription,
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: .default,
                                                  handler: nil))
                    
                    self.present(alert, animated: true)
                }
            }
        } else {
            // dl document is not registered
            let alert = UIAlertController(title: "Oh no ...",
                                          message: "Please enroll drivers license.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    private func createVerifiableCredentials(from type: VCType, withURL vcsURL: String) -> Void {
        switch type {
        // create verfiable document from enrolled 'dl'
        // at this time, only 'dl' document is supported
        case .document:
            // get public key for service url
            ServiceDirectory.sharedInstance.getServicePublickey(serviceURL: vcsURL) { (result, error) in
                if error == nil {
                    if let result = result,
                       let publicKey = result["publicKey"] as? String {
                        print("VCS Public Key: ", publicKey as String, "\n")
                        
                        let vDocument = ["did": BlockIDSDK.sharedInstance.getDID(),
                                         "document": self.registeredDocument!]
                        
                        VerifiableCredentialsHelper.shared.createVerifiableCredentialsFromDocument(document: vDocument,
                                                                                                   serviceURL: vcsURL,
                                                                                                   publicKey: publicKey) { (result, error) in
                            print("Result: ", result as Any, "\n")
                            print("Error: ", error as Any, "\n")
                        }
                    } else {
                        // public key not found for 'vcs' url
                        // probably 'vcs' servie url is missing
                        // show error message
                        let alert = UIAlertController(title: "Oh no ...",
                                                      message: "Verifiable credentials service is not available for the requested tenant. Please contact support team.",
                                                      preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "OK",
                                                      style: .default,
                                                      handler: nil))

                        self.present(alert, animated: true)
                    }
                } else {
                    // show error message
                    let alert = UIAlertController(title: "Oh no ...",
                                                  message: error?.localizedDescription,
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: .default,
                                                  handler: nil))
                    
                    self.present(alert, animated: true)
                }
            }
        // create verfiable document from payload
        // to be done later
        case .payload:
            print("Create VC from payload.")
        }
    }
}

// MARK: - PKAddPassesViewControllerDelegate -
extension MyCardsViewController: PKAddPassesViewControllerDelegate {
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        self.dismiss(animated: true)
    }
}
