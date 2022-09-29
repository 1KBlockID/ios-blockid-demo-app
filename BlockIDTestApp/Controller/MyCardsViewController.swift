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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func addToAppleWallet(sender: Any) {
        self.addCardToAppleWallet()
    }
}

// MARK: - Extension -
extension MyCardsViewController {
    private func addCardToAppleWallet() -> Void {
        // reading pass file data from local file;
        // the data should come from API
        if let path = Bundle.main.url(forResource: passes.randomElement(),
                                      withExtension: "pkpass") {
            do {
                let passJSON = try Data(contentsOf: path)
                
                do {
                    // Create Pass Object
                    let pass = try PKPass(data: passJSON)

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
