//
//  DriverLicenseViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import AVFoundation
import BlockID
import Toast_Swift
import UIKit
  
class DriverLicenseViewController: UIViewController {

    private var dlScannerHelper: DriverLicenseScanHelper?
    private let firstScanningDocSide: DLScanningSide = .DL_BACK
    private let expiryDays = 90
    private var _scanLine: CAShapeLayer!
    private var manualCaptureImg: UIImage?
    
    var isLivenessNeeded: Bool = false
    
    @IBOutlet private weak var _viewBG: UIView!
    @IBOutlet private weak var _viewLiveIDScan: BIDScannerView!
    @IBOutlet private weak var _imgOverlay: UIImageView!
    @IBOutlet private weak var _lblScanInfoTxt: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        startDLScanning()
        
       /* NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.numberOfFacesNotification(_:)),
                                               name: NSNotification.Name(rawValue: "BlockIDFaceDetectionNotification"),
                                               object: nil) */
    }

   /* override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "BlockIDFaceDetectionNotification"),
                                                  object: nil)
    } */

 /*   @objc func numberOfFacesNotification(_ notification: Notification) {
        guard let faceCount = notification.userInfo?["numberOfFaces"] as? Int else { return }
        print ("Number of faces found: \(faceCount)")
        DispatchQueue.main.async {
            if faceCount > 0 {
                self._lblScanInfoTxt.text = "Faces found : \(faceCount)"
            } else {
                self._lblScanInfoTxt.text = "Scan Front"
            }
        }
    }
*/
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Cancellation warning!",
                                      message: "Do you want to cancel the registration process?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.dlScannerHelper?.stopDLScanning()
            self.goBack()
        }))
        self.present(alert, animated: true)
        return
        
    }
    
    private func startDLScanning() {
        //1. Check for Camera Permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if !response {
                //2. Show Alert
                DispatchQueue.main.async {
                    self.alertForCameraAccess()
                }
            } else {
                // Camera access given
                DispatchQueue.main.async {
                    self.showDocumentScannerFor(.DL, self)
                    //3. Initialize dlScannerHelper
//                    if self.dlScannerHelper == nil {
//                        self._viewBG.isHidden = true
//                        self._viewLiveIDScan.isHidden = true
//                        self.dlScannerHelper = DriverLicenseScanHelper.init(dlScanResponseDelegate: self)
//                    }
//                    //4. Start Scanning
//                    self.dlScannerHelper?.startDLScanning(scanningSide: self.firstScanningDocSide)
                }
            }
        }
    }

   /* private func wantToVerifyAlert(withDLData dl: [String : Any]?, token: String) {
        let alert = UIAlertController(title: "Verification",
                                      message: "Do you want to verify your Drivers License?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
            self.setDriverLicense(withDLData: dl, token: token)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.verifyDL(withDLData: dl, token: token)
        }))
        
        self.present(alert, animated: true)
    }
    
    private func verifyDL(withDLData dl: [String: Any]?, token: String) {
        self.view.makeToastActivity(.center)
        
        BlockIDSDK.sharedInstance.verifyDocument(dvcID: AppConsant.dvcID, dic: dl ?? [:], verifications: ["dl_verify"]) { [self] (status, dataDic, error) in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    if !status {
                        //Verification failed
                        self.view.makeToast(error?.message ?? "Verification Failed", duration: 3.0, position: .center, title: "Error", completion: {_ in
                            self.goBack()
                        })
                        return
                    }
                    
                    //Verification success, call documentRegistration API
                    
                    // - Recommended for future use -
                    // Update DL dictionary to include array of token recieved
                    // from verifyDocument API response.
                    if let dataDict = dataDic, let certifications = dataDict["certifications"] as? [[String: Any]], var dlObj = dl {
                        var tokens = [String]()
                        for certification in certifications {
                            let token = certification["token"] as? String ?? ""
                            tokens.append(token)
                        }
                        dlObj["tokens"] = tokens
                        self.setDriverLicense(withDLData: dlObj, token: token)
                    } else {
                        self.setDriverLicense(withDLData: dl, token: token)
                    }
                }
            }
        }
    }
  
    private func setDriverLicense(withDLData dl: [String : Any]?, token: String) {
        
        self.view.makeToastActivity(.center)
        var dic = dl
        dic?["category"] = RegisterDocCategory.Identity_Document.rawValue
        dic?["type"] = RegisterDocType.DL.rawValue
        dic?["id"] = dl?["id"]
        BlockIDSDK.sharedInstance.registerDocument(obj: dic ?? [:], sigToken: token) { [self] (status, error) in
            DispatchQueue.main.async {
                self.view.hideToastActivity()
                if !status {
                    // FAILED
                    if error?.code == CustomErrors.kLiveIDMandatory.code {
                        DocumentStore.sharedInstance.setData(documentData: dic, token: token)
                        self.goBack()
                        self.showLiveIDView()
                        return
                    }
                    
                    self.view.makeToast(error?.message, duration: 3.0, position: .center, title: "Error", completion: {_ in
                        self.goBack()
                    })
                    return
                }
                // SUCCESS
                self.view.makeToast("Drivers License enrolled successfully.", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
                    self.goBack()
                })
            }
        }
    }
    
    private func scanCompleteUIUpdates() {
        self._lblScanInfoTxt.text = "Scan Complete"
        if let scanLine = _scanLine {
            scanLine.removeAllAnimations()
        }
    }*/
}

// MARK: - DocumentSessionScanDelegate -
extension DriverLicenseViewController: DocumentSessionScanDelegate {
   
    func onDocumentScanResponse(status: Bool, document: [String: Any]?, error: ErrorResponse?) {
        debugPrint("******", status, error?.message as Any)
        if error?.code == CustomErrors.DocumentScanner.CANCELED.code { // Cancelled
            self.goBack()
        }
    }
}


/*extension DriverLicenseViewController: DriverLicenseResponseDelegate {
    func verifyingDocument() {
        self.view.makeToastActivity(.center)
    }
    
    func dlScanCompleted(dlScanSide: DLScanningSide, dictDriveLicense: [String : Any]?, signatureToken signToken: String?, error: ErrorResponse?) {
       
        if (error?.code == CustomErrors.kScanCancelled.code) {
            // Document scanner cancelled/Error
            self.goBack()
        }
        
        if error?.code == CustomErrors.kUnauthorizedAccess.code {
            self.showAppLogin()
        }
        // Check if DL is Expired...
        if error?.code == CustomErrors.kDocumentExpired.code {
            self.view.makeToast(error?.message,
                                duration: 3.0,
                                position: .center)
            return
        }
        
        // DL Module not enabled...
        if error?.code == CustomErrors.License.MODULE_NOT_ENABLED.code {
            let localizedMessage = "MODULE_NOT_ENABLED".localizedMessage(CustomErrors.License.MODULE_NOT_ENABLED.code)
            self.view.makeToast(localizedMessage,
                                duration: 3.0,
                                position: .center)
            return
        }
        
        scanCompleteUIUpdates()
        
        guard var dl = dictDriveLicense, let token = signToken else {
            self.view.makeToast(error?.message,
                                duration: 3.0,
                                position: .center)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.goBack()
            }
            return
            
        }
            dl["isLivenessRequired"] = false
        if isLivenessNeeded {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            if let documentLivenessVC = storyBoard.instantiateViewController(withIdentifier: "DocumentLivenessViewController") as? DocumentLivenessViewController {
                documentLivenessVC.onLivenessFinished = { (sender) in
                    if let sender = sender {
                        sender.navigationController?.popViewController(animated: false)
                        dl["isLivenessRequired"] = true 
                        if error?.code == CustomErrors.kDocumentAboutToExpire.code {
                            //About to Expire, Show Alert
                            let alert = UIAlertController(title: "Error", message: error!.message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                                self.setDriverLicense(withDLData: dl, token: token)
                            }))
                            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            return
                        }
                        self.setDriverLicense(withDLData: dl, token: token)
                    }
                }
                self.navigationController?.pushViewController(documentLivenessVC, animated: false)
                return
            }
        }
        showVerificationAlert(dl: dl, token: token, error: error)
    }
    
    private func showVerificationAlert(dl: [String: Any], token: String, error: ErrorResponse?) {
        //Check if Not to Expiring Soon
        if error?.code != CustomErrors.kDocumentAboutToExpire.code {
            self.wantToVerifyAlert(withDLData: dl, token: token)
            return
        }
        
        //About to Expire, Show Alert
        let alert = UIAlertController(title: "Error", message: error!.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.wantToVerifyAlert(withDLData: dl, token: token)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func scanFrontSide() {
        DispatchQueue.main.async {
            self._lblScanInfoTxt.text = "Scan Front"
            self.dlScannerHelper?.startDLScanning(scanningSide: .DL_FRONT)
        }
    }
    
    func scanBackSide() {
        DispatchQueue.main.async {
            self._lblScanInfoTxt.text = "Scan Back"
            self.dlScannerHelper?.startDLScanning(scanningSide: .DL_BACK)
        }
    }
      
      func readyForDetection() {
            DispatchQueue.main.async {
                //Check if there are any existing animations
                if !(self._scanLine.animationKeys()?.count ?? 0 > 0) {
                    self.animateScanLine(_scanLine: self._scanLine, height:  self._imgOverlay.frame.height)
                   
            }
          }
      }
}
*/
