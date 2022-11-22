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
    
    // holds card details data in tableview
    private var cardDetails: [[String: Any]] = []
    
    // selected card index
    var selectedCardIndex: Int = -1
    
    // selected card
    var selectedCard: [String: Any] = [:] {
        didSet {
            self.prepareCardDatasource(with: selectedCard)
        }
    }
    
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
        
        // update card view details
        self.updateCardView(with: self.selectedCard)
    }
    
    // MARK: - IBActions -
    @IBAction func addToAppleWallet(sender: Any) {
        self.addCardToAppleWallet()
    }
}

// MARK: - Extension: UI Update -
extension VFCCardDetailsViewController {
    private func showNavigationBar(yorn: Bool) {
        self.navigationController?.setNavigationBarHidden(!yorn,
                                                          animated: false)
    }
    
    private func setupNavigationBarButtons() {
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
    
    @objc private func done() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func deleteCard() {
        // Create An UIAlertController with Action Sheet
        let optionsController = UIAlertController(title: nil,
                                                  message: "Are you sure you want to delete this card?",
                                                  preferredStyle: .actionSheet)
        
        // Create UIAlertAction for UIAlertController
        // Delete
        let deleteAction = UIAlertAction(title: "Delete",
                                         style: .destructive,
                                         handler: { (alert: UIAlertAction!) in
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
    
    private func addCardToAppleWallet() {
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

// MARK: - Extension: Business Logic -
extension VFCCardDetailsViewController {
    // prepare card view details datasource
    func prepareCardDatasource(with details: [String: Any]) {
        // get docType
        let type: String = details["docType"] as! String
        
        // get vfc details
        let vfc: [String: Any] = details["vfc"] as! [String: Any]
        
        // get credentialSubject
        let credentialSubject: [String: Any] = vfc["credentialSubject"] as! [String: Any]
        
        // based on card type, update card datasource
        // to be presented in tableview
        if type == CardType.identity_dl.rawValue {
            // get issuer
            if let issuer: String = vfc["issuer"] as? String {
                self.cardDetails.append(["Issued by": issuer])
            } else {
                self.cardDetails.append(["Issued by": ""])
            }
                       
            self.cardDetails.append(["Credential Type": "Verified Identity"])
            self.cardDetails.append(["Document Scanned": "Driver’s License"])
            
            if let firstName = credentialSubject["firstName"] as? String {
                self.cardDetails.append(["First Name": firstName])
            } else {
                self.cardDetails.append(["First Name": ""])
            }
            
            if let lastName = credentialSubject["lastName"] as? String {
                self.cardDetails.append(["Last Name": lastName])
            } else {
                self.cardDetails.append(["Last Name": ""])
            }
            
            if let dob = credentialSubject["dob"] as? String,
               let formattedDoB = self.formatDateForDisplay(date: dob) {
                self.cardDetails.append(["Date of Birth": formattedDoB])
            } else {
                self.cardDetails.append(["Date of Birth": ""])
            }
            
            // prepare address: street, city, state zipcode
            if let street = credentialSubject["street"] as? String,
               let city = credentialSubject["city"] as? String,
               let state = credentialSubject["state"] as? String,
               let zipcode = credentialSubject["zipCode"] as? String {
                self.cardDetails.append(["Address": "\(street), \(city), \(state) \(zipcode)"])
            } else {
                self.cardDetails.append(["Address": ""])
            }
            
            // AAMVA verificaiton to be done
            self.cardDetails.append(["Verified By": "AAMVA"])
        } else if type == CardType.employee_card.rawValue {
//            // get issuer
//            let issuer: [String: Any] = vfc["issuer"] as! [String: Any]
//            if let name: String = issuer["name"] as? String {
//                self.cardDetails.append(["Issued by": name])
//            } else {
//                self.cardDetails.append(["Issued by": ""])
//            }
            // get issuer
            if let issuer: String = vfc["issuer"] as? String {
                self.cardDetails.append(["Issued by": issuer])
            } else {
                self.cardDetails.append(["Issued by": ""])
            }
            
            self.cardDetails.append(["Credential Type": "Verfied Employee"])
            
            if let firstName = credentialSubject["firstName"] as? String {
                self.cardDetails.append(["First Name": firstName])
            } else {
                self.cardDetails.append(["First Name": ""])
            }
            
            if let lastName = credentialSubject["lastName"] as? String {
                self.cardDetails.append(["Last Name": lastName])
            } else {
                self.cardDetails.append(["Last Name": ""])
            }
            
            if let employeeId = credentialSubject["employeeId"] as? String {
                self.cardDetails.append(["Employee ID": employeeId])
            } else {
                self.cardDetails.append(["Employee ID": ""])
            }

            if let companyName = credentialSubject["companyName"] as? String {
                self.cardDetails.append(["Company Name": companyName])
            } else {
                self.cardDetails.append(["Company Name": ""])
            }

            if let department = credentialSubject["department"] as? String {
                self.cardDetails.append(["Department": department])
            } else {
                self.cardDetails.append(["Department": ""])
            }

            if let address: String = credentialSubject["companyAddress"] as? String {
                self.cardDetails.append(["Company Address": address])
            } else {
                self.cardDetails.append(["Company Address": ""])
            }
        }
    }
    
    private func formatDateForDisplay(date: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let fromDate = formatter.date(from: date) {
            formatter.dateFormat = "MMM dd, yyyy"
            return formatter.string(from: fromDate)
        }
        
        return nil
    }
    
    private func setupCardDetailsViewAppearance() {
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
    
    private func updateCardView(with details: [String: Any]?) {
        if let details = details {
            // get docType
            let type: String = details["docType"] as! String
            
            // get vfc details
            let vfc: [String: Any] = details["vfc"] as! [String: Any]
            
            switch type {
            case CardType.identity_dl.rawValue:
                // set card type
                cardView.type = .identity_dl
                
                // set as per FIGMA UI
                cardView.imageView?.image = UIImage(named: "imgIidentityLogo.png")
                
                // set as per FIGMA UI
                cardView.typeText?.text = "Verified Identity"
                
                // set from response object
                if let issuer: String = vfc["issuer"] as? String {
                    cardView.issuerText?.text = issuer
                } else {
                    cardView.issuerText?.text = "N.A."
                }
            case CardType.employee_card.rawValue:
                // set card type
                cardView.type = .employee_card
                
                // set as per FIGMA UI
                cardView.imageView?.image = UIImage(named: "imgCompanyLogo.png")
                
                // set as per FIGMA UI
                cardView.typeText?.text = "Verified Employee"
//                // set from response object
//                let issuer: [String: Any] = vfc["credentialSubject"] as! [String: Any]
//                cardView.issuerText?.text = issuer["companyName"] as? String
                
                // set from response object
                if let issuer: String = vfc["issuer"] as? String {
                    cardView.issuerText?.text = issuer
                } else {
                    cardView.issuerText?.text = "N.A."
                }
            default:
                // Any unsupported type
                // set default values
                cardView.type = .none
                cardView.imageView?.image = nil
                cardView.typeText?.text = ""
                cardView.issuerText?.text = ""
            }
        }
    }
    
    private func updateCardViewDetails(for cell: UITableViewCell, at indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.textLabel?.text = self.cardDetails[indexPath.row].keys.first
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12.0,
                                                 weight: UIFont.Weight.semibold)
        cell.textLabel?.textColor = UIColor(red: 0.675,
                                            green: 0.675,
                                            blue: 0.675,
                                            alpha: 1.0)
        
        cell.detailTextLabel?.text = (self.cardDetails[indexPath.row].values.first as? String)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0,
                                                       weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.textColor = UIColor(red: 0.255,
                                                  green: 0.255,
                                                  blue: 0.255,
                                                  alpha: 1.0)
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
        return self.cardDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: "VFCCardDetailTableViewCell") {
            cell = reusableCell
        } else {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                                   reuseIdentifier: "VFCCardDetailTableViewCell")
        }
        
        // update card details
        self.updateCardViewDetails(for: cell, at: indexPath)
        
        return cell
    }
}
