//
//  VFCCardDetailsViewController.swift
//  BlockIDTestApp
//
//  Created by Sushil Tiwari on 03/10/22.
//

import UIKit
import PassKit

class VFCCardDetailsViewController: UIViewController {
    
    // define list of pass
    // to be removed later
    let passes = ["BoardingPass", "Event", "Generic", "StoreCard", "Coupon"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set title
        self.title = "Card Details"
        
        // show navigation bar
        self.showNavigationBar(yorn: true)
    }

    // MARK: - IBActions -
    @IBAction func addToAppleWallet(sender: Any) {
        self.addCardToAppleWallet()
    }
}

// MARK: - Extension: Private Methods -
extension VFCCardDetailsViewController {

    private func showNavigationBar(yorn: Bool) -> Void {
        self.navigationController?.setNavigationBarHidden(!yorn,
                                                          animated: false)
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
extension VFCCardDetailsViewController: PKAddPassesViewControllerDelegate {
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        self.dismiss(animated: true)
    }
}
