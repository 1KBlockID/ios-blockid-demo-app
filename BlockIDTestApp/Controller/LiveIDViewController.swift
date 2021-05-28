//
//  LiveIDViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import UIKit
import AVFoundation
import BlockIDSDK

struct DetectionMsg {
    static let blink = "Please blink your eyes"
    static let smile = "Please smile"
}

class LiveIDViewController: UIViewController {
    
    var isForVerification: Bool = false
    var isForConsent: Bool = false
    private var attemptCounts = 0
   
    private var liveIdScannerHelper: LiveIDScannerHelper?
    private let selectedMode: ScanningMode = .SCAN_LIVE


    @IBOutlet private weak var _viewBG: UIView!
    @IBOutlet private weak var _viewLiveIDScan: BIDScannerView!
    @IBOutlet private weak var _imgOverlay: UIImageView!
    @IBOutlet private weak var _lblInformation: UILabel!
    @IBOutlet private weak var _lblPageTitle: UILabel!
            
    override func viewDidLoad() {
        super.viewDidLoad()
        _viewBG.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isForVerification {
            //For LiveID Verification
            _lblPageTitle.text = "LiveID Authentication"
        }
        startLiveIDScanning()
    }
    
    private func startLiveIDScanning() {
        //1. Check for Camera Permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if !response {
                //2. Show Alert
                DispatchQueue.main.async {
                    self.alertForCameraAccess()
                }
            } else {
                DispatchQueue.main.async {
                    self._viewBG.isHidden = false
                    self._lblInformation.isHidden = true

                    //3. Initialize LiveIDScannerHelper
                    if self.liveIdScannerHelper == nil {
                        self.liveIdScannerHelper = LiveIDScannerHelper.init(scanningMode: self.selectedMode, bidScannerView: self._viewLiveIDScan, liveIdResponseDelegate: self)
                    }
                    //4. Start Scanning
                    self.liveIdScannerHelper?.startLiveIDScanning()
                }
            }
        }
        
    }
    
    private func updateUIWithLivenessFactor(_ factor: LivenessFactorType) {

        switch factor {
            case .BLINK:
                _lblInformation.text = DetectionMsg.blink
            case .SMILE:
                _lblInformation.text = DetectionMsg.smile
        }
    }
    
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to cancel the registration process?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.stopLiveIDScanning()
            self.goBack()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        self.present(alert, animated: true)
        return
    }
    
    private func setLiveID(withPhoto face: UIImage, token: String) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.setLiveID(liveIdImage: face, liveIdProofedBy: "", sigToken: token) { [self] (status, error) in
            self.view.hideToastActivity()
            if !status {
                // FAILED
                self.view.makeToast(error?.message, duration: 3.0, position: .center, title: "Error!", completion: {_ in
                    self.goBack()
                })
                return
            }
            // SUCCESS
            self.stopLiveIDScanning()
            self.view.makeToast("LiveID enrolled successfully", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
                self.goBack()
            })

        }
    }
    
    private func registerLiveIDWithDocument(withPhoto face: UIImage, token: String) {
        self.view.makeToastActivity(.center)
        let documentData = DocumentStore.sharedInstance.getDocumentStoreData()
        guard let obj = documentData.documentData else { return  }
        let docType = DocumentStore.sharedInstance.docType!
        let docSignToken = DocumentStore.sharedInstance.token ?? ""
        let type = DocumentStore.sharedInstance.type ?? ""
        let jsonStr = CommonFunctions.objectToJSONString(obj)
        var dic = CommonFunctions.jsonStringToDic(from: jsonStr)
        dic?["category"] = RegisterDocCategory.Identity_Document.rawValue
        dic?["type"] = type
        dic?["id"] = obj.id
        
        BlockIDSDK.sharedInstance.registerDocument(obj: dic ?? [:], docType: docType, liveIdProofedBy: "", docSignToken: docSignToken, faceImage: face, liveIDSignToken: token) { [self] (status, error) in
            self.view.hideToastActivity()
            DocumentStore.sharedInstance.clearData()
            // SUCCESS
            self.stopLiveIDScanning()
            if !status {
                // FAILED
                self.view.makeToast(error?.message, duration: 3.0, position: .center, title: "Error!", completion: {_ in
                    self.goBack()
                })
                return
            }

            self.view.makeToast("Document enrolled successfully", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
                self.goBack()
            })

        }
    }
    
    private func verifyLiveID(withPhoto photo: UIImage, token: String) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.verifyLiveID(image: photo, sigToken: token) { (status, error) in
            self.view.hideToastActivity()
            if !status {
                //If verification is for User Consent
                if self.isForConsent {
                    self.attemptCounts += 1
                    debugPrint("LiveID: Current attempts = \(self.attemptCounts)")
                    if self.attemptCounts == 3 {
                        self.attemptCounts = 0
                        //Failed 3 attempts
                        //Finish Process with false status
                        self.stopLiveIDScanning()
                        self.goBack()
                        return
                    }
                    self.liveIdScannerHelper = nil
                    self.startLiveIDScanning()
                    return
                }
                //Verification failed, show error
                self.showErrorDialog(error)
                return
            }
            //Verification successful
            self.goBack()
        }
    }
    
    private func showErrorDialog(_ error: ErrorResponse?) {
        var title: String? = nil
        var msg: String? = nil
        if error?.code == NSURLErrorNotConnectedToInternet {
            title = ErrorConfig.noInternet.title
            msg = ErrorConfig.noInternet.message
        }
        else if (error != nil && error?.code == CustomErrors.kUnauthorizedAccess.code) {
            self.showAppLogin()
        }
        else {
            msg = error!.message
        }
        self.view.makeToast(msg, duration: 3.0, position: .center, title: title, completion: {_ in
            self.goBack()
        })
    }
    
    private func stopLiveIDScanning() {
        guard let running = liveIdScannerHelper?.isRunning() else { return }
        if running {
            self.liveIdScannerHelper?.stopLiveIDScanning()
        }
    }
}

extension LiveIDViewController: LiveIDResponseDelegate {
    
    func focusOnFaceChanged(isFocused: Bool?) {
        _lblInformation.isHidden = !(isFocused)!
        _imgOverlay.tintColor = isFocused! ? UIColor.green :  UIColor.red
    }
    
    func readyForExpression(_ expression: LivenessFactorType) {
        updateUIWithLivenessFactor(expression)
    }
        
    func liveIdDetectionCompleted(_ liveIdImage: UIImage?, signatureToken: String?, error: ErrorResponse?) {
        
        //Check If licenene key not enabled
        if error?.code == CustomErrors.kLicenseyKeyNotEnabled.code {
            self.view.makeToast(error?.message, duration: 3.0, position: .center, title: ErrorConfig.error.title, completion: {_ in
                
                self.goBack()
            })
            return
        }
        
        
        
        guard let face = liveIdImage, let signToken = signatureToken else {
            self.view.makeToast(ErrorConfig.error.message, duration: 3.0, position: .center, title: ErrorConfig.error.title, completion: {_ in
                if (error != nil && error?.code == CustomErrors.kUnauthorizedAccess.code) {
                    self.showAppLogin()
                }
                else {
                    self.goBack()
                }
            })
            return

        }

        if isForVerification {
            // Verify LiveID
            self.verifyLiveID(withPhoto: face, token: signToken)
        } else {
            // Set LiveID
            if DocumentStore.sharedInstance.hasData() {
                self.registerLiveIDWithDocument(withPhoto: face, token: signToken)
                return
            }
            self.setLiveID(withPhoto: face, token: signToken)

        }
    }
    
}

