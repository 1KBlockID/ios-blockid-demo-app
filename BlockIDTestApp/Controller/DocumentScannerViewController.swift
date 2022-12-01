//
//  DocumentScannerViewController.swift
//  BlockIDTestApp
//
//  Created by Prasanna gupta on 30/11/22.
//

import UIKit
import AVFoundation
import BlockIDSDK

class DocumentScannerViewController: UIViewController {
   
    private lazy var dlPayload = [String: Any]()
    private lazy var selfiePayload = [String: Any]()
    
    @IBOutlet private weak var viewActivityIndicator: UIView!
    @IBOutlet private weak var activityIndicator: CustomActivityIndicator!
    @IBOutlet private weak var lblActivityIndicator: UILabel!
    
    // MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startDLScanning()
    }
}

// MARK: - Private Methods -
extension DocumentScannerViewController {
    
    private func startDLScanning() {
        // 1. Check for Camera Permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if !response {
                // 2. Show Alert
                DispatchQueue.main.async {
                    self.alertForCameraAccess()
                }
            } else {
                DispatchQueue.main.async {
                    DocumentScannerHelper.shared.startDLScan(from: self)
                    { status, data, error in
                        if status {
                            guard let dictionary = data else { return }
                            // Got DL Scan data, go for LiveID Scan
                            self.scanLiveID(dlDataDic: dictionary)
                        } else {
                            if let err = error {
                                self.showErrorDialog(err)
                            } else {
                                self.goBack()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    private func showErrorDialog(_ error: ErrorResponse?) {
        var title: String? = nil
        var msg: String? = nil
        if (error != nil && error?.code == CustomErrors.kUnauthorizedAccess.code) {
            self.showAppLogin()
        } else if error?.code == NSURLErrorNotConnectedToInternet ||
            error?.code == CustomErrors.Network.OFFLINE.code {
            msg = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
            title = ErrorConfig.noInternet.title
        } else {
            msg = error!.message
        }
        self.view.makeToast(msg, duration: 3.0,
                            position: .center,
                            title: title, completion: {_ in
            self.goBack()
        })
    }
}


// MARK: - DL Enrollment -
extension DocumentScannerViewController {
    
    /// **Scan LiveID**
    ///
    /// This func will scan the LiveID using SelfieScanner which will give the near selfie and the far selfie data.
    ///
    /// - Parameter dlDataDic: A DL data dictionary from DocumentScanner which will be passed to verifyDL
    ///
    private func scanLiveID(dlDataDic: [String: Any]) {
        SelfieScannerHelper.shared.startLiveIDScan(from: self)
        { status, data, error in
            if status {
                // Got Data
                guard let dic = data else { return }
                self.selfiePayload = dic
                
                // Verify DL
                self.verifyDL(withDLData: dlDataDic)
                
            } else {
                // Abort process
                if let err = error {
                    self.showErrorDialog(err)
                    return
                }
                self.goBack()
            }
        }
    }
    
    /// Verifies DL data before registration
    ///
    /// This func will verify the scanned Driver License against an authenticator
    ///
    /// - Parameter driverLicense: A Driver License data dictionary
    ///
    private func verifyDL(withDLData driverLicense: [String: Any]?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.lblActivityIndicator.text = "EXTRACT_DATA".localizedMessage(0)
            self.viewActivityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        })
        
        VerifyDocumentHelper.shared.verifyDL(withDLData: driverLicense) { status, error in
            if !status {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showErrorDialog(error)
                }
            } else {
                guard let dlObjDic = certifications[0]["result"] as? [String: Any] else { return }
                self?.dlPayload = dlObjDic
                
                // LiveID NOT Enrolled, verify doc with face_liveness
                if !BlockIDSDK.sharedInstance.isLiveIDRegisterd() {
                    self?.checkLiveness()
                    return
                }
                // LiveID Enrolled, verify doc with face_compare
                self?.compareFace()
            }
        }
    }

    /// Compares faces from Driver License and LiveId.
    ///
    /// This calls compareFace() func of **VerifyDocumentHelper** and acts on provided response from it.
    ///
    private func compareFace() {
        DispatchQueue.main.async {
            self.lblActivityIndicator.text = "MATCHING_SELFIE".localizedMessage(0)
        }
        let liveIdBase64 = selfiePayload[VerifyDocumentHelper.shared.kLiveId] as? String
        let documentFaceBase64 = dlPayload["face"] as? String

        guard let liveIdBase64 = liveIdBase64,
              let documentFaceBase64 = documentFaceBase64 else {
            let msg = "FACE_COMPARISON_FAILED".localizedMessage(0)
            let error = ErrorResponse(code: 1007, msg: msg)
            self.showErrorDialog(error)
            return
        }
        
        VerifyDocumentHelper.shared.compareFace(base64Image1: liveIdBase64,
                                                base64Image2: documentFaceBase64)
        { status, error in
            if !status {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showErrorDialog(error)
                }
                return
            }
            // Register DL
            self.setDriverLicense(withDLData: self.dlPayload, token: "")
        }
        
    }
    
    /// **Checks Face liveness**
    ///
    /// This calls checkLiveness() func of **VerifyDocumentHelper** and acts on provided response from it.
    ///
    private func checkLiveness() {
        let liveIdBase64 = selfiePayload[VerifyDocumentHelper.shared.kLiveId] as? String
        DispatchQueue.main.async {
            self.lblActivityIndicator.text = "VALIDATING_LIVENESS".localizedMessage(0)
        }
        guard let liveIdBase64 = liveIdBase64 else { return }
        VerifyDocumentHelper.shared.checkLiveness(liveIDBase64: liveIdBase64)
        { status, error in
            if !status {
                self.activityIndicator.stopAnimating()
                self.showErrorDialog(error)
                return
            }
            // Register DL with LiveId
            self.registerDocumentWithLiveid()
        }
    }
    
    /// **Register DL**
    ///
    /// This calls registerDocument func of the BlockID SDK to register a document
    ///
    private func setDriverLicense(withDLData driverLicense: [String: Any]?,
                                  token: String?) {
        viewActivityIndicator.isHidden = false
        activityIndicator.startAnimating()
        self.lblActivityIndicator.text = "REGISTER_DATA".localizedMessage(0)

        var dic = driverLicense
        dic?[VerifyDocumentHelper.shared.kCategory] = RegisterDocCategory.Identity_Document.rawValue
        dic?[VerifyDocumentHelper.shared.kType] = RegisterDocType.DL.rawValue
        dic?[VerifyDocumentHelper.shared.kID] = driverLicense?[VerifyDocumentHelper.shared.kID]

        if let dic = dic {
            BlockIDSDK.sharedInstance.registerDocument(obj: dic,
                                                       sigToken: token)
            { [self] (status, error) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.lblActivityIndicator.text = nil
                    self.viewActivityIndicator.isHidden = true
                    if !status {
                        // FAILED
                        self.showErrorDialog(error)
                        return
                    }
                    // SUCCESS
                    self.view.makeToast("DL_ENROLLED".localizedMessage(0),
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
    
    /// **Register DL with LiveID**
    ///
    /// This calls registerDocument with LiveID func of the BlockID SDK to register a document with the LiveID
    ///
    private func registerDocumentWithLiveid() {
        guard let imgDataStr = selfiePayload[VerifyDocumentHelper.shared.kLiveId] as? String,
                let imgdata = Data(base64Encoded: imgDataStr, options: .ignoreUnknownCharacters),
              let img = UIImage(data: imgdata) else {
                return
              }
        DispatchQueue.main.async {
            self.lblActivityIndicator.text = "REGISTER_DATA".localizedMessage(0)
        }
        BlockIDSDK.sharedInstance.registerDocument(obj: dlPayload,
                                                   liveIdProofedBy: "blockid",
                                                   docSignToken: nil,
                                                   faceImage: img,
                                                   liveIDSignToken: nil) { status, error in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.lblActivityIndicator.text = nil
                self.viewActivityIndicator.isHidden = true
                if !status {
                    self.showErrorDialog(error)
                    return
                }
                // SUCCESS
                self.view.makeToast("DL_ENROLLED".localizedMessage(0),
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
