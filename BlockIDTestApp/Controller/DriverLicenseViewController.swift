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

    private let kDLFailedMessage = "Drivers License failed to scan."
    
    private var liveIdFace: String!
    private var proofedBy: String!

    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var imgLoader: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startDLScanning()
    }
    
    private func goBack() {
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController.isKind(of: EnrollMentViewController.self) {
                    self.navigationController?.popToViewController(viewController, animated: true)
                }
            }
            return
        }
        self.navigationController?.popViewController(animated: true)
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
                    
                    // Show document scanner View controller
                    self.showDocumentScannerFor(.DL, self)
                }
            }
        }
    }

    private func showVerifyAlert(withDLData dl: [String : Any]?, _ sessionId: String?) {
        let alert = UIAlertController(title: "Verification",
                                      message: "Do you want to verify your Drivers License?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
            self.setDriverLicense(withDLData: dl, sessionId)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.verifyDL(withDLData: dl, sessionId)
        }))
        
        self.present(alert, animated: true)
    }
    
    private func verifyDL(withDLData dl: [String: Any]?, _ sessionId: String?) {
        
        BlockIDSDK.sharedInstance.verifyDocument(dvcID: AppConsant.dvcID, dic: dl ?? [:], verifications: ["dl_verify"], mobileSessionId: sessionId, mobileDocumentId: "dl_"+UUID().uuidString) { [self] (status, dataDic, error) in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    if !status {
                        //Verification failed
                        self.showAlertAndMoveBack(title: "Error",
                                                  message: error?.message ?? "Verification Failed")
                        return
                    }
                    
                    //Verification success, call documentRegistration API
                    
                    // - Recommended for future use -
                    // Update DL dictionary to include array of token recieved
                    // from verifyDocument API response.
                    if let dataDic = dataDic,
                       let dictResult = dataDic["result"] as? [String: Any],
                       let certifications = dictResult["certifications"] as? [[String: Any]],
                       var dlObj = dl {
                        var tokens = [String]()
                        for certification in certifications {
                            let token = certification["token"] as? String ?? ""
                            tokens.append(token)
                        }
                        dlObj["tokens"] = tokens
                        self.setDriverLicense(withDLData: dlObj, sessionId)
                    } else {
                        self.setDriverLicense(withDLData: dl, sessionId)
                    }
                }
            }
        }
    }
  
    private func setDriverLicense(withDLData dl: [String : Any]?, _ sessionId: String?) {
        var dic = dl
        dic?["category"] = RegisterDocCategory.Identity_Document.rawValue
        dic?["type"] = RegisterDocType.DL.rawValue
        dic?["id"] = dl?["id"]
        
        if !BlockIDSDK.sharedInstance.isLiveIDRegisterd() {
            self.registerWithLiveID(dic: dic, sessionId)
        } else {
            self.registerWithOutLiveID(dic: dic, sessionId)
        }
        
    }
    
    private func registerWithLiveID(dic: [String: Any]?, _ mobileSessionId: String?) {
        guard let imgB64Str = self.liveIdFace,
              let imgdata = Data(base64Encoded: imgB64Str,
                                 options: .ignoreUnknownCharacters),
              let img = UIImage(data: imgdata) else {
            return
        }
        let mobileDocumentId = "dl_with_live_id_" + UUID().uuidString
        BlockIDSDK.sharedInstance.registerDocument(obj: dic ?? [:],
                                                   liveIdProofedBy: self.proofedBy,
                                                   faceImage: img,
                                                   mobileSessionId: mobileSessionId,
                                                   mobileDocumentId: mobileDocumentId)
        { [self] (status, error) in
            DispatchQueue.main.async {
                if !status {
                    // FAILED
                    self.showAlertAndMoveBack(title: "Error",
                                              message: error?.message ?? self.kDLFailedMessage)
                    return
                }
                // SUCCESS
                self.view.makeToast("Drivers License enrolled successfully.",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Thank you!",
                                    completion: {_ in
                    self.goBack()
                })
            }
        }
    }
    
    private func registerWithOutLiveID(dic: [String: Any]?, _ mobileSessionId: String?) {
        let mobileDocumentId = "dl_" + UUID().uuidString
        BlockIDSDK.sharedInstance.registerDocument(obj: dic ?? [:],
                                                   mobileSessionId: mobileSessionId,
                                                   mobileDocumentId: mobileDocumentId) { [self] (status, error) in
            DispatchQueue.main.async {
                if !status {
                    // FAILED
                    if error?.code == CustomErrors.kLiveIDMandatory.code {
                        DocumentStore.sharedInstance.setData(documentData: dic)
                        self.goBack()
                        self.showLiveIDView()
                        return
                    }
                    
                    self.showAlertAndMoveBack(title: "Error",
                                              message: error?.message ?? self.kDLFailedMessage)
                    return
                }
                // SUCCESS
                self.view.makeToast("Drivers License enrolled successfully.",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Thank you!",
                                    completion: {_ in
                    self.goBack()
                })
            }
        }
    }
}

// MARK: - DocumentSessionScanDelegate -
extension DriverLicenseViewController: DocumentScanDelegate {
   
    func onDocumentScanResponse(status: Bool, document: String?, sessionID: String?, error: ErrorResponse?) {
        
        if !status {
            if error?.code == CustomErrors.kUnauthorizedAccess.code {
                self.showAppLogin()
                return
            }
            
            if error?.code == CustomErrors.License.MODULE_NOT_ENABLED.code {
                let localizedMessage = "MODULE_NOT_ENABLED".localizedMessage(CustomErrors.License.MODULE_NOT_ENABLED.code)
                self.showAlertAndMoveBack(title: "Error", message: localizedMessage)
                return
            }
            
            if error?.code == CustomErrors.DocumentScanner.CANCELED.code { // Cancelled
                self.goBack()
                return
            }
            
            if error?.code == CustomErrors.DocumentScanner.TIMEOUT.code {
                self.showAlertAndMoveBack(title: "Error",
                                          message: "Scanning time exceeded. To continue, please restart the scanning process.")
                return
            }
            
            self.showAlertAndMoveBack(title: "Error",
                                      message: error?.message ?? kDLFailedMessage)
            return
        }
        
        guard let documentObject = document,
              !documentObject.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
            return
        }
        guard let dictDocObject = CommonFunctions.jsonStringToDic(from: documentObject) else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
            return
        }
        guard let responseStatus = dictDocObject["responseStatus"] as? String,
              !responseStatus.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
            return
        }
        if responseStatus.uppercased() == "FAILED" {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
            return
        }
        guard let token = dictDocObject["token"] as? String,
              !token.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
            return
        }
        guard var dictDLObject = dictDocObject["dl_object"] as? [String: Any] else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
            return
        }
        guard let proof_jwt = dictDLObject["proof_jwt"] as? String,
              !proof_jwt.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kDLFailedMessage)
            return
        }
        
        if let liveIdObj = dictDocObject["liveid_object"] as? [String: Any] {
            self.liveIdFace = liveIdObj["face"] as? String
            self.proofedBy = liveIdObj["proofedBy"] as? String
        }
        dictDLObject["proof"] = proof_jwt
        dictDLObject["certificate_token"] = token
        DocumentStore.sharedInstance.setSessionId(sessionID)
        self.showVerifyAlert(withDLData: dictDLObject, sessionID)
    }
    
    private func showAlertAndMoveBack(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.goBack()
        }))
        self.present(alert, animated: true)
    }
}
