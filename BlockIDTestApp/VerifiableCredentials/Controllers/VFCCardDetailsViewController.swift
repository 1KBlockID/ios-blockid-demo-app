//
//  VFCCardDetailsViewController.swift
//  BlockIDTestApp
//
//  Created by Sushil Tiwari on 03/10/22.
//

import UIKit
import PassKit

class VFCCardDetailsViewController: UIViewController {
    
    // selected card
    var selectedCard: [String: Any]?
    var selectedCardIndex: Int = -1
    
    // define list of pass
    // to be removed later
    let passes = ["BoardingPass", "Event", "Generic", "StoreCard", "Coupon"]
    
    // MARK: - IBOutlets -
    @IBOutlet weak var tblCardDetail: UITableView!
    @IBOutlet weak var cardView: CardView!
    
    // MARK: - View Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show navigation bar
        self.showNavigationBar(yorn: true)
        
        // add button items
        self.setupNavigationBarButtons()
        
        // setup tableview appearance
        self.setupCardDetailsViewAppearance()
        
        // setup card view appearance
        self.setupCardViewAppearanceFor(card: self.selectedCard)
    }
    
    // MARK: - IBActions -
    @IBAction func addToAppleWallet(sender: Any) {
        self.addCardToAppleWallet()
    }
}

// MARK: - Extension: Private Methods -
extension VFCCardDetailsViewController {
    
    private func setupCardDetailsViewAppearance() -> Void {
        self.tblCardDetail.contentInset = UIEdgeInsets(top: -38.0,
                                                       left: 0.0,
                                                       bottom: -38.0,
                                                       right: 0.0)
        self.tblCardDetail.layer.cornerRadius = 10.0
        self.tblCardDetail.layer.borderColor = UIColor(red: 0.980,
                                                       green: 0.933,
                                                       blue: 0.937,
                                                       alpha: 1.0).cgColor
        self.tblCardDetail.layer.borderWidth = 1.0
        self.tblCardDetail.layer.backgroundColor = UIColor(red: 1.0,
                                                           green: 1.0,
                                                           blue: 1.0,
                                                           alpha: 1.0).cgColor
    }
    
    private func setupCardViewAppearanceFor(card: [String: Any]?) -> Void {
        let type: [String] = self.selectedCard!["type"] as! [String]
        cardView.type = (type.last == "DriversLicenseCredential") ? .identity : .employee
    }
    
    private func showNavigationBar(yorn: Bool) -> Void {
        self.navigationController?.setNavigationBarHidden(!yorn,
                                                          animated: false)
    }
    
    private func setupNavigationBarButtons() -> Void {
        // create left bar button item
        let leftButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(self.done))
        
        // set left bar button item
        self.navigationItem.setLeftBarButton(leftButton,
                                             animated: true)
        
        
        // create right bar button item
        let rightButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                          target: self,
                                          action: #selector(self.deleteCard))
        
        // set right bar button item
        self.navigationItem.setRightBarButton(rightButton,
                                              animated: true)
    }
    
    @objc private func done() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func deleteCard() -> Void {
        // Create An UIAlertController with Action Sheet
        let optionsController = UIAlertController(title: nil,
                                                  message: "Are you sure you want to delete the card?",
                                                  preferredStyle: .actionSheet)
        
        // Create UIAlertAction for UIAlertController
        // Delete
        let deleteAction = UIAlertAction(title: "Delete",
                                         style: .destructive,
                                         handler: { (alert: UIAlertAction!) -> Void in
            if var cards = UserDefaults.standard.value(forKey: "VFC_CARDS") as? [[String: Any]] {
                cards.remove(at: self.selectedCardIndex)
                UserDefaults.standard.set(cards, forKey: "VFC_CARDS")
                self.navigationController?.popViewController(animated: true)
            }
        })
        
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        // Add UIAlertAction in UIAlertController
        optionsController.addAction(deleteAction)
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
extension VFCCardDetailsViewController: PKAddPassesViewControllerDelegate {
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource -
extension VFCCardDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: "VFCCardDetailTableViewCell") {
            cell = reusableCell
        } else {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                                   reuseIdentifier: "VFCCardDetailTableViewCell")
        }
        
        cell.selectionStyle = .none
        
        // FIXME: - Hardcoded data for now -
        // will fix it as part of another ticket
        cell.textLabel?.text = "Document Scanned"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12.0,
                                                 weight: UIFont.Weight.semibold)
        cell.textLabel?.textColor = UIColor(red: 0.675,
                                            green: 0.675,
                                            blue: 0.675,
                                            alpha: 1.0)
        
        let type: [String] = self.selectedCard!["type"] as! [String]
        cell.detailTextLabel?.text = "\(type[1] as String)"
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0,
                                                       weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.textColor = UIColor(red: 0.255,
                                                  green: 0.255,
                                                  blue: 0.255,
                                                  alpha: 1.0)
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension VFCCardDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}
