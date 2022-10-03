//
//  MyCardsViewController.swift
//  BlockIDTestApp
//
//  Created by Sushil Tiwari on 29/09/22.
//

import UIKit
import BlockIDSDK

class MyCardsViewController: UIViewController {
    
    // enrolled drivers licenses
    private var registeredDocument: [String: Any]?
    
    // datasource
    private var cardsDataSource: [[String: Any]] = []
    
    // MARK: - IBOutlets -
    @IBOutlet weak var lblNoCards: UILabel!
    @IBOutlet weak var tblCardsView: UITableView!
    
    // MARK: - View Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get enrolled drivers license
        self.registeredDocument = self.getRegisteredDocument(type: RegisterDocType.DL.rawValue)
        
        // read stored vfc cards
//        UserDefaults.standard.set([], forKey: "VFC_CARDS")
        if let cards = UserDefaults.standard.value(forKey: "VFC_CARDS") as? [[String: Any]] {
            self.cardsDataSource = cards
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set title
        self.title = "Verified ID's"
        
        // show navigation bar
        self.showNavigationBar(yorn: true)
        
        // add button items
        self.setupNavigationBarButtons()
        
        //
        self.lblNoCards.isHidden = (self.cardsDataSource.count == 0) ? false : true
        self.tblCardsView.isHidden = !self.lblNoCards.isHidden
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // hide navigation bar
        self.showNavigationBar(yorn: false)
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
        self.navigationController?.setNavigationBarHidden(!yorn,
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
    
    private func showProgressIndicator() -> Void {
        // show progress bar
        self.view.makeToastActivity(.center)

        // disable user interaction
        self.view.window?.isUserInteractionEnabled = false
    }
    
    private func hideProgressIndicator() -> Void {
        // hide progress indicator
        self.view.hideToastActivity()

        // enable user interaction
        self.view.window?.isUserInteractionEnabled = true
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
            self.intiateAddIDCardUsingEnrolledDocument()
        })
        
        // Scan QR
        let scanQRAction = UIAlertAction(title: "Scan QR",
                                         style: .default,
                                         handler: { (alert: UIAlertAction!) -> Void in
            self.intiateAddCardUsingQRScan()
        })
        
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        // Add UIAlertAction in UIAlertController
        optionsController.addAction(addIDAction)
        optionsController.addAction(scanQRAction)
        optionsController.addAction(cancelAction)
        
        // Present UIAlertController with Action Sheet
        self.present(optionsController,
                     animated: true,
                     completion: nil)
    }
    
    private func intiateAddIDCardUsingEnrolledDocument() -> Void {
        // check is drivers license document is enrolled
        // else show an error message
        if self.registeredDocument != nil {
            // show progress indicator
            self.showProgressIndicator()
            
            // dl document is registered
            // prepare verifiable document
            let vcDocument: [String: Any] = ["did": BlockIDSDK.sharedInstance.getDID(),
                                             "document": self.registeredDocument!]
            
            // and get verifiable credential now
            VerifiableCredentialsHelper.shared.createVerifiableCredentials(for: VerifiableCredential.document_dl,
                                                                           with: vcDocument) { (result, error) in
                if error == nil, let result = result {
                    // no error, process the result
                    // add to card datasource
                    self.cardsDataSource.append(result)
                    
                    // add the entire datasource to user defaults
                    UserDefaults.standard.set(self.cardsDataSource,
                                              forKey: "VFC_CARDS")
                    
                    // update the UI; reload the table view
                    self.lblNoCards.isHidden = true
                    self.tblCardsView.isHidden = !self.lblNoCards.isHidden
                    self.tblCardsView.reloadData()
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
                
                // hide progress indicator
                self.hideProgressIndicator()
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
    
    private func intiateAddCardUsingQRScan() -> Void {
        // show progress indicator
        self.showProgressIndicator()
        
        // verify payload
        let verifyDoc: [String: Any] = ["@context": ["https://www.w3.org/2018/credentials/v1",
                                                     ["EmploymentCredential": "https://schema.org#EmploymentCredential",
                                                      "firstName": "https://schema.org#firstName",
                                                      "lastName": "https://schema.org#lastName",
                                                      "companyName": "https://schema.org#companyName",
                                                      "companyAddress": "https://schema.org#companyAddress",
                                                      "department": "https://schema.org#department",
                                                      "employeeId": "https://schema.org#employeeId",
                                                      "doe": "https://schema.org#doe"],
                                                     "https://w3id.org/security/suites/ed25519-2020/v1"],
                                        "id": "did:blockid:1fe1567fd53c18e3720bf0474103b459b84410af",
                                        "type": ["VerifiableCredential",
                                                 "EmploymentCredential"],
                                        "issuer": ["id": "TBD",
                                                   "name": "1KOSMOS",
                                                   "address": "Mumbai, India"],
                                        "issuanceDate": "2022-10-03",
                                        "expirationDate": "2050-06-12",
                                        "credentialSubject": ["id": "did:blockid:1fe1567fd53c18e3720bf0474103b459b84410af",
                                                              "firstName": "Sushil",
                                                              "lastName": "Tiwari",
                                                              "companyName": "1KOSMOS",
                                                              "companyAddress": "Mumbai, India",
                                                              "department": "Engineering",
                                                              "employeeId": "1234678",
                                                              "doe": "2050-06-12"],
                                        "proof": ["type": "Ed25519Signature2020",
                                                  "created": "2022-10-03T17:50:14Z",
                                                  "verificationMethod": "did:key:z6MkkoREMRc69kLhD92EqQkte1K7eks1SvjUzRcULqVQpEhM#z6MkkoREMRc69kLhD92EqQkte1K7eks1SvjUzRcULqVQpEhM",
                                                  "proofPurpose": "assertionMethod",
                                                  "proofValue": "z654uQ27jGHLGLeBoZFwFXExwjKJbJ1TSQjosSidjYmQa7LRedGk4XGpptrr78yrA1PXhSSwtHMmjdykvUjL3pm36"]]
        
        VerifiableCredentialsHelper.shared.verify(vc: ["vc": verifyDoc]) { (verifyResult, verifyError) in
            if verifyError == nil, let result = verifyResult,
                let status = result["status"] as? String, status == "verified" {
                // no error, process the result
                // add to card datasource
                self.cardsDataSource.append(verifyDoc)
                
                // add the entire datasource to user defaults
                UserDefaults.standard.set(self.cardsDataSource,
                                          forKey: "VFC_CARDS")
                
                // update the UI; reload the table view
                self.lblNoCards.isHidden = true
                self.tblCardsView.isHidden = !self.lblNoCards.isHidden
                self.tblCardsView.reloadData()
            } else {
                // show error message
                let alert = UIAlertController(title: "Oh no ...",
                                              message: verifyError?.localizedDescription,
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK",
                                              style: .default,
                                              handler: nil))

                self.present(alert, animated: true)
            }
            
            // hide progress indicator
            self.hideProgressIndicator()
        }
    }
}

// MARK: - UITableViewDataSource -
extension MyCardsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cardsDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: "MyCardsTableViewCell") {
            cell = reusableCell
        } else {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                                   reuseIdentifier: "MyCardsTableViewCell")
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        let card = self.cardsDataSource[indexPath.row]
        let credentialSubject: [String: Any] = card["credentialSubject"] as! [String: Any]
        let type: [String] = card["type"] as! [String]
        
        cell.textLabel?.text = "\(credentialSubject["firstName"] as! String) \(credentialSubject["lastName"] as! String)"
        cell.detailTextLabel?.text = "\(type[1] as  String)"
        
        return cell
    }
}

// MARK: - UITableViewDelegate -
extension MyCardsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vfcCardDetailVC = VFCCardDetailsViewController(nibName: "VFCCardDetailsViewController",
                                                           bundle: nil)
        self.navigationController?.pushViewController(vfcCardDetailVC,
                                                      animated: true)
    }
}
