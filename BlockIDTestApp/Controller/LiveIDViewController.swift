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
    static let left = "Please turn left"
    static let right = "Please turn right"
}

class LiveIDViewController: UIViewController {
    
    var isLiveIDV0: Bool = false
    var isForVerification: Bool = false
    var isForConsent: Bool = false
    
    private var attemptCounts = 0
   
    private var liveIdScannerHelper: LiveIDScannerHelper?
    private var liveIDV0ScanHelper: LiveIDV0ScannerHelper?
    private let selectedMode: ScanningMode = .SCAN_LIVE


    @IBOutlet private weak var _viewBG: UIView!
    @IBOutlet private weak var _viewLiveIDScan: BIDScannerView!
    @IBOutlet private weak var _imgOverlay: UIImageView!
    @IBOutlet private weak var _lblInformation: UILabel!
    @IBOutlet private weak var _lblPageTitle: UILabel!
            
    override func viewDidLoad() {
        super.viewDidLoad()
        _viewBG.isHidden = true
        _imgOverlay.isHidden = true
        _lblInformation.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isForVerification {
            //For LiveID Verification
            _lblPageTitle.text = "LiveID Authentication"
        }
        if isLiveIDV0 {
            startLiveIDV0Scanning()
            return
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
                    
                    let bidView = BIDScannerView()
                    bidView.frame = self._viewLiveIDScan.frame
                    self.view.addSubview(bidView)
                    self._viewLiveIDScan.isHidden = true
                    
                    //3. Initialize LiveIDScannerHelper
                    if self.liveIdScannerHelper == nil {
                        self.liveIdScannerHelper = LiveIDScannerHelper.init(scanningMode: self.selectedMode, bidScannerView: bidView, liveIdResponseDelegate: self)
                    }
                    //4. Start Scanning
                    self.liveIdScannerHelper?.startLiveIDScanning()
                }
            }
        }
        
    }
    
    private func startLiveIDV0Scanning() {
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
                    self._viewLiveIDScan.isHidden = false
                    
                    //3. Initialize LiveIDScannerHelper
                    if self.liveIDV0ScanHelper == nil {
                        self.liveIDV0ScanHelper = LiveIDV0ScannerHelper.init(scanningMode: self.selectedMode, bidScannerView: self._viewLiveIDScan, liveIdResponseDelegate: self)
                    }
                    //4. Start Scanning
                    self.liveIDV0ScanHelper?.startLiveIDScanning()
                }
            }
        }
        
    }
    
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to cancel the registration process?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: {_ in
            if self.isLiveIDV0 {
                self.stopLiveIDV0Scanning()
            } else {
                self.stopLiveIDScanning()
            }
            self.goBack()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))

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
            if self.isLiveIDV0 {
                self.stopLiveIDV0Scanning()
            } else {
                self.stopLiveIDScanning()
            }
            self.view.makeToast("LiveID enrolled successfully", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
                self.goBack()
            })

        }
    }
    
    private func registerLiveIDWithDocument(withPhoto face: UIImage, token: String) {
        self.view.makeToastActivity(.center)
        let documentData = DocumentStore.sharedInstance.getDocumentStoreData()
        guard let obj = documentData.documentData else { return  }
        let docSignToken = DocumentStore.sharedInstance.token ?? ""
        
        BlockIDSDK.sharedInstance.registerDocument(obj: obj, liveIdProofedBy: "", docSignToken: docSignToken, faceImage: face, liveIDSignToken: token) { [self] (status, error) in
            self.view.hideToastActivity()
            DocumentStore.sharedInstance.clearData()
            // SUCCESS
            if self.isLiveIDV0 {
                self.stopLiveIDV0Scanning()
            } else {
                self.stopLiveIDScanning()
            }
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
                        if self.isLiveIDV0 {
                            self.stopLiveIDV0Scanning()
                        } else {
                            self.stopLiveIDScanning()
                        }
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
        self.liveIdScannerHelper?.stopLiveIDScanning()
    }
    
    private func stopLiveIDV0Scanning() {
        self.liveIDV0ScanHelper?.stopLiveIDScanning()
    }
}

extension LiveIDViewController: LiveIDResponseDelegate {

    func liveIdDetectionCompleted(_ liveIdImage: UIImage?, signatureToken: String?, error: ErrorResponse?) {
        
        //Check If licenene key not enabled
        if error?.code == CustomErrors.kLicenseyKeyNotEnabled.code {
            self.view.makeToast(error?.message, duration: 3.0, position: .center, title: ErrorConfig.error.title, completion: {_ in
                
                self.goBack()
            })
            return
        }
        
        if error?.code == CustomErrors.kLiveIDWithARNotSupported.code {
            let alert = UIAlertController(title: "Error",
                                          message: "The LiveID scan is not supported on this device. (Error Code: \(error?.code ?? 000)",
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.goBack()
            }))

            self.present(alert, animated: true)
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
    
    func readyForExpression(_ livenessFactor: LivenessFactorType) {
        DispatchQueue.main.async {
            self._lblInformation.isHidden = false

            switch livenessFactor {
            case .BLINK:
                self._lblInformation.text = DetectionMsg.blink
            case .SMILE:
                self._lblInformation.text = DetectionMsg.smile
            case .MOVE_LEFT:
                self._lblInformation.text = DetectionMsg.left
            case .MOVE_RIGHT:
                self._lblInformation.text = DetectionMsg.right
            case .NONE:
                return
            @unknown default:
                return
            }
        }

    }
    
    func focusOnFaceChanged(isFocused: Bool?) {
        guard let inFocus = isFocused else {
            return
        }
        if !inFocus {
            DispatchQueue.main.async {
                self._lblInformation.text = "Please try again"
            }
        }
    }
    
    func wrongExpressionDetected(_ livenessFactor: LivenessFactorType) {
        var factor = ""
        switch livenessFactor {
        case .BLINK:
            factor = "Blink"
        case .SMILE:
            factor = "Smile"
        case .MOVE_LEFT:
            factor = "Moved Left"
        case .MOVE_RIGHT:
            factor = "Moved Right"
        case .NONE:
            return
        }
        
        self._lblInformation.text = "Wrong Expression: \(factor)"
    }
    
}

extension LiveIDViewController: LiveIDV0ResponseDelegate {
    
    func readyForExpression(_ livenessFactor: LivenessFactorTypeV0) {
        DispatchQueue.main.async {
            self._lblInformation.isHidden = false

            switch livenessFactor {
            case .BLINK:
                self._lblInformation.text = DetectionMsg.blink
            case .SMILE:
                self._lblInformation.text = DetectionMsg.smile
            }
        }
    }
    
    
    
}
