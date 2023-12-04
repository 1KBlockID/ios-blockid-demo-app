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
    private let kDLFailedMessage = "Drivers License failed to scan."
    
    var isLivenessNeeded: Bool = false
    
    @IBOutlet private weak var _viewBG: UIView!
    @IBOutlet private weak var _viewLiveIDScan: BIDScannerView!
    @IBOutlet private weak var _imgOverlay: UIImageView!
    @IBOutlet private weak var _lblScanInfoTxt: UILabel!
    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var imgLoader: UIImageView!
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch AVAudioSession.sharedInstance().recordPermission {
           case .granted:
            startDLScanning()
               print("Permission granted")
           case .denied:
               print("Permission denied")
           case .undetermined:
               print("Request permission here")
               AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                   // Handle granted
                   self.startDLScanning()
               })
           @unknown default:
               print("Unknown case")
           }
    }

    // MARK:
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
                    // Start loader spin
                    self.rotateView(self.imgLoader)
                    self.showDocumentScannerFor(.DL, self)
                }
            }
        }
    }

    private func wantToVerifyAlert(withDLData dl: [String : Any]?, token: String) {
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
        
        BlockIDSDK.sharedInstance.verifyDocument(dvcID: AppConsant.dvcID, dic: dl ?? [:], verifications: ["dl_verify"]) { [self] (status, dataDic, error) in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    if !status {
                        //Verification failed
                        self.view.makeToast(error?.message ?? "Verification Failed",
                                            duration: 3.0,
                                            position: .center,
                                            title: "Error", completion: {_ in
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
        var dic = dl
        dic?["category"] = RegisterDocCategory.Identity_Document.rawValue
        dic?["type"] = RegisterDocType.DL.rawValue
        dic?["id"] = dl?["id"]
        BlockIDSDK.sharedInstance.registerDocument(obj: dic ?? [:], sigToken: token) { [self] (status, error) in
            DispatchQueue.main.async {
                if !status {
                    // FAILED
                    if error?.code == CustomErrors.kLiveIDMandatory.code {
                        DocumentStore.sharedInstance.setData(documentData: dic)
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
}

// MARK: - DocumentSessionScanDelegate -
extension DriverLicenseViewController: DocumentScanDelegate {
   
    func onDocumentScanResponse(status: Bool, document: String?, error: ErrorResponse?) {
        
        if error?.code == CustomErrors.kUnauthorizedAccess.code {
            self.showAppLogin()
        }
        
        if error?.code == CustomErrors.License.MODULE_NOT_ENABLED.code {
            let localizedMessage = "MODULE_NOT_ENABLED".localizedMessage(CustomErrors.License.MODULE_NOT_ENABLED.code)
            self.showAlertAndMoveBack(title: "Error",
                                      message: localizedMessage)
            return
        }
        
        if error?.code == CustomErrors.DocumentScanner.CANCELED.code { // Cancelled
            self.goBack()
        }
       
        if error?.code == CustomErrors.DocumentScanner.TIMEOUT.code {
            self.showAlertAndMoveBack(title: "Error",
                                      message: "Scanning time exceeded. To continue, please restart the scanning process.")
            return
        }
        
        guard let dlObject = document else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
           return
        }
        guard let dictDocObject = CommonFunctions.jsonStringToDic(from: dlObject) else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
            return
        }
        guard let responseStatus = dictDocObject["responseStatus"] as? String else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
           return
        }
        if responseStatus == "FAILED" {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
          return
        }
        guard let token = dictDocObject["token"] as? String, !token.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
            return
        }
        guard var dictDLObject = dictDocObject["dl_object"] as? [String: Any] else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
           return
        }
        guard let proof_jwt = dictDLObject["proof_jwt"] as? String, !proof_jwt.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
            return
        }
        
        dictDLObject["proof"] = proof_jwt
        dictDLObject["certificate_token"] = token
        self.setDriverLicense(withDLData: dictDLObject, token: "")
    }
    
    private func showAlertAndMoveBack(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.goBack()
        }))
        self.present(alert, animated: true)
    }
}
