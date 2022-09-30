//
//  MyCardsViewController.swift
//  BlockIDTestApp
//
//  Created by Sushil Tiwari on 29/09/22.
//

import UIKit
import PassKit

class MyCardsViewController: UIViewController {
    
    // define list of pass
    let passes = ["BoardingPass", "Event", "Generic", "StoreCard", "Coupon"]

    // MARK: - View Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    private func showNavigationBar(yorn: Bool) -> Void {
        self.navigationController?.setNavigationBarHidden(yorn,
                                                          animated: false)
    }
    
    private func setupNavigationBarButtons() -> Void {
        
        // create right bar button item
        let rightButton = UIBarButtonItem(barButtonSystemItem: .add,
                                          target: self,
                                          action: #selector(self.addCard))
        
        // set right bar button item
        self.navigationItem.setRightBarButton(rightButton,
                                              animated: true)
    }
    
    @objc private func addCard() -> Void {
        // Create An UIAlertController with Action Sheet
        let optionsController = UIAlertController(title: nil,
                                                     message: "Choose Option from Action Sheet",
                                                     preferredStyle: .actionSheet)
        
        // Create UIAlertAction for UIAlertController
        // Add ID
        let addIDAction = UIAlertAction(title: "Add ID",
                                      style: .default,
                                      handler: { (alert: UIAlertAction!) -> Void in
            print("Add ID")
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
}

// MARK: - PKAddPassesViewControllerDelegate -
extension MyCardsViewController: PKAddPassesViewControllerDelegate {
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        self.dismiss(animated: true)
    }
}
