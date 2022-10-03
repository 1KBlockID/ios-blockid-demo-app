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
        // UserDefaults.standard.set([], forKey: "VFC_CARDS")
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
        self.openQRScanner()
    }
    
    private func openQRScanner() -> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let scanQRVC = storyboard.instantiateViewController(withIdentifier: "ScanQRViewController") as! ScanQRViewController
        scanQRVC.delegate = self
        self.present(scanQRVC, animated: true)
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

// MARK: - ScanQRViewDelegate -
extension MyCardsViewController: ScanQRViewDelegate {
    func scannedData(data: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // show progress indicator
            self.showProgressIndicator()
            
            let qrPayload = Data(data.utf8)
            do {
                if let document = try JSONSerialization.jsonObject(with: qrPayload) as? [String: Any],
                   let vcPayload = document["vc"] as? [String: Any] {
                    VerifiableCredentialsHelper.shared.verify(vc: document) { (verifyResult, verifyError) in
                        print("Result: ", verifyResult as Any, "\n")
                        print("Error: ", verifyError as Any, "\n")
                        if verifyError == nil, let result = verifyResult,
                           let status = result["status"] as? String, status == "verified" {
                            // no error, process the result
                            // add to card datasource
                            self.cardsDataSource.append(vcPayload)
                            
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
                    }
                } else {
                    // show error message
                    let alert = UIAlertController(title: "Oh no ...",
                                                  message: "Invalid QR code. Try again.",
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: .default,
                                                  handler: nil))
                    
                    self.present(alert, animated: true)
                }
                
                // hide progress indicator
                self.hideProgressIndicator()
            } catch {
                // show error message
                let alert = UIAlertController(title: "Oh no ...",
                                              message: "some exception when converting JSON to object",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK",
                                              style: .default,
                                              handler: nil))
                
                self.present(alert, animated: true)
                
                // hide progress indicator
                self.hideProgressIndicator()
            }
        }
    }
}
