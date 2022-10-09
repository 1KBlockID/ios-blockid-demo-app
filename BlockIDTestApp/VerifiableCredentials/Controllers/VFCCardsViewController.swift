//
//  MyCardsViewController.swift
//  BlockIDTestApp
//
//  Created by Sushil Tiwari on 29/09/22.
//

import UIKit
import BlockIDSDK

class VFCCardsViewController: UIViewController {
    
    // enrolled drivers licenses
    private var registeredDocument: [String: Any]?
    
    // datasource
    private var cardsDataSource: [[String: Any]] = []
    
    // MARK: - IBOutlets -
    @IBOutlet weak var lblNoCards: UILabel!
    @IBOutlet weak var ucvCardsView: UICollectionView!
    
    // MARK: - View Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get enrolled drivers license
        self.registeredDocument = self.getRegisteredDocument(type: RegisterDocType.DL.rawValue)
        
        // register UICollectionView
        self.ucvCardsView.register(CardsCollectionViewCell.self, forCellWithReuseIdentifier: "CardsCollectionViewCell")
        
        // read stored vfc cards
        if let cards = UserDefaults.standard.value(forKey: "VFC_CARDS") as? [[String: Any]] {
            self.cardsDataSource = cards
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set title
        self.title = "Verified IDs"
        
        // show navigation bar
        self.showNavigationBar(yorn: true)
        
        // add button items
        self.setupNavigationBarButtons()
        
        // read stored vfc cards
        if let cards = UserDefaults.standard.value(forKey: "VFC_CARDS") as? [[String: Any]] {
            self.cardsDataSource = cards
            self.ucvCardsView.reloadData()
        }
        
        //
        self.lblNoCards.isHidden = (self.cardsDataSource.count == 0) ? false : true
        self.ucvCardsView.isHidden = !self.lblNoCards.isHidden
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // hide navigation bar
        self.showNavigationBar(yorn: false)
    }
}

// MARK: - Extension: UI Update -
extension VFCCardsViewController {
    private func showNavigationBar(yorn: Bool) {
        self.navigationController?.setNavigationBarHidden(!yorn,
                                                          animated: false)
    }
    
    private func setupNavigationBarButtons() {
        // create right bar button item
        let rightButton = UIBarButtonItem(barButtonSystemItem: .add,
                                          target: self,
                                          action: #selector(self.showOptionsSheet))
        
        // set right bar button item
        self.navigationItem.setRightBarButton(rightButton,
                                              animated: true)
    }
    
    private func showProgressIndicator() {
        // show progress bar
        self.view.makeToastActivity(.center)
        
        // disable user interaction
        self.view.window?.isUserInteractionEnabled = false
    }
    
    private func hideProgressIndicator() {
        // hide progress indicator
        self.view.hideToastActivity()
        
        // enable user interaction
        self.view.window?.isUserInteractionEnabled = true
    }
    
    @objc private func showOptionsSheet() {
        // Create An UIAlertController with Action Sheet
        let optionsController = UIAlertController(title: nil,
                                                  message: "Select card option",
                                                  preferredStyle: .actionSheet)
        
        // Create UIAlertAction for UIAlertController
        // Add ID
        let addIDAction = UIAlertAction(title: "Add ID",
                                        style: .default,
                                        handler: { (alert: UIAlertAction!) in
            self.addCardUsingEnrolledDocument()
        })
        
        // Scan QR
        let scanQRAction = UIAlertAction(title: "Scan QR",
                                         style: .default,
                                         handler: { (alert: UIAlertAction!) in
            self.addCardUsingQRScan()
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
    
    private func addCardUsingQRScan() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let scanQRVC = storyboard.instantiateViewController(withIdentifier: "ScanQRViewController") as! ScanQRViewController
        scanQRVC.delegate = self
        self.present(scanQRVC, animated: true)
    }
}

// MARK: - Extension: Business Logic -
extension VFCCardsViewController {
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
    
    private func addCardUsingEnrolledDocument() {
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
                    self.cardsDataSource.append(["docType": CardType.identity_dl.rawValue,
                                                 "vfc": result])
                    
                    // add the entire datasource to user defaults
                    UserDefaults.standard.set(self.cardsDataSource,
                                              forKey: "VFC_CARDS")
                    
                    // update the UI; reload the table view
                    self.lblNoCards.isHidden = true
                    self.ucvCardsView.isHidden = !self.lblNoCards.isHidden
                    self.ucvCardsView.reloadData()
                    
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
    
    private func updateCardView(cardView: CardView, with details: [String: Any]) {
        // get docType
        let type: String = details["docType"] as! String
        
        // get vfc details
        let vfc: [String: Any] = details["vfc"] as! [String: Any]
        
        if type == CardType.identity_dl.rawValue {
            // set card type
            cardView.type = .identity_dl
            
            // set as per FIGMA UI
            cardView.imageView?.image = UIImage(named: "imgIidentityLogo.png")

            // set as per FIGMA UI
            cardView.typeText?.text = "Verified Identity"
            
            // set from response object
            let issuer: [String: Any] = vfc["issuer"] as! [String: Any]
            cardView.issuerText?.text = issuer["id"] as? String
        } else if type == CardType.employee_card.rawValue {
            // set card type
            cardView.type = .employee_card
            
            // set as per FIGMA UI
            cardView.imageView?.image = UIImage(named: "imgCompanyLogo.png")

            // set as per FIGMA UI
            cardView.typeText?.text = "Verified Employee"
            // set from response object
            let issuer: [String: Any] = vfc["credentialSubject"] as! [String: Any]
            cardView.issuerText?.text = issuer["companyName"] as? String
        } else {
            // Any unsupported type
            // set default values
            cardView.type = .none
            cardView.imageView?.image = nil
            cardView.typeText?.text = ""
            cardView.issuerText?.text = ""
        }
    }
}

// MARK: - ScanQRViewDelegate -
extension VFCCardsViewController: ScanQRViewDelegate {
    func scannedData(data: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // show progress indicator
            self.showProgressIndicator()
            
            let qrPayload = Data(data.utf8)
            do {
                if let document = try JSONSerialization.jsonObject(with: qrPayload) as? [String: Any],
                   let vcPayload = document["vc"] as? [String: Any] {
                    VerifiableCredentialsHelper.shared.verify(vc: document) { (verifyResult, verifyError) in
//                        print("Result: ", verifyResult as Any, "\n")
//                        print("Error: ", verifyError as Any, "\n")
                        if verifyError == nil, let result = verifyResult,
                           let status = result["status"] as? String, status == "verified" {
                            // no error, process the result
                            // add to card datasource
                            self.cardsDataSource.append(["docType": CardType.employee_card.rawValue,
                                                         "vfc": vcPayload])
                            
                            // add the entire datasource to user defaults
                            UserDefaults.standard.set(self.cardsDataSource,
                                                      forKey: "VFC_CARDS")
                            
                            // update the UI; reload the table view
                            self.lblNoCards.isHidden = true
                            self.ucvCardsView.isHidden = !self.lblNoCards.isHidden
                            self.ucvCardsView.reloadData()
                            
                            // hide progress indicator
                            self.hideProgressIndicator()
                        } else {
                            // show error message
                            let alert = UIAlertController(title: "Oh no ...",
                                                          message: verifyError?.localizedDescription,
                                                          preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK",
                                                          style: .default,
                                                          handler: nil))
                            
                            self.present(alert, animated: true)
                            
                            // hide progress indicator
                            self.hideProgressIndicator()
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
                    
                    // hide progress indicator
                    self.hideProgressIndicator()
                }
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

// MARK: - UICollectionViewDataSource -
extension VFCCardsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.cardsDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardsCollectionViewCell",
                                                      for: indexPath)
        
        if let cardView = cell.viewWithTag(101) as? CardView {
            let currentCard: [String: Any] = self.cardsDataSource[indexPath.section]
            self.updateCardView(cardView: cardView,
                                with: currentCard)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate -
extension VFCCardsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let vfcCardDetailVC = VFCCardDetailsViewController(nibName: "VFCCardDetailsViewController",
                                                           bundle: nil)
        vfcCardDetailVC.selectedCard = self.cardsDataSource[indexPath.section]
        vfcCardDetailVC.selectedCardIndex = indexPath.section
        self.navigationController?.pushViewController(vfcCardDetailVC,
                                                      animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout -
extension VFCCardsViewController: UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: 220.0)
    }
}
