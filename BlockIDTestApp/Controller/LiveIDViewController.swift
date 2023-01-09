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
    static let up = "Move your head up"
    static let down = "Move your head down"
}

/*
 
 Adding Feedback Generator
 
 */
enum Vibration {
        case error
        case success
        case warning
        case light
        case medium
        case heavy
        @available(iOS 13.0, *)
        case soft
        @available(iOS 13.0, *)
        case rigid
        case selection
        case oldSchool

        public func vibrate() {
            switch self {
            case .error:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .success:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .warning:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case .light:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .medium:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case .heavy:
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            case .soft:
                if #available(iOS 13.0, *) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            case .rigid:
                if #available(iOS 13.0, *) {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            case .oldSchool:
                //FIXME: - Need to be fixed
                print("old school----->")
                //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }


class LiveIDViewController: UIViewController {
    
    var isForVerification: Bool = false
    var isForConsent: Bool = false
    
    private var attemptCounts = 0
   
    private var liveIdScannerHelper: LiveIDScannerHelper?
    private let selectedMode: ScanningMode = .SCAN_LIVE
    private let isResettingExpressionsAllowed = false
    private var isLoaderHidden: Bool = false
    var isLivenessNeeded: Bool = false
    private var imgOverlay: UIImageView!
    var onFinishCallback: ((_ status: Bool) -> Void)?

    @IBOutlet private weak var _viewBG: UIView!
    @IBOutlet private weak var _viewLiveIDScan: BIDScannerView!
    @IBOutlet private weak var _imgOverlay: UIImageView!
    @IBOutlet private weak var _lblInformation: UILabel!
    @IBOutlet private weak var _lblPageTitle: UILabel!

    // MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        _viewBG.isHidden = true
       // _imgOverlay.isHidden = true
        _lblInformation.isHidden = true
        
        if isLivenessNeeded {
            _lblPageTitle.text = "Enroll Live ID (with Liveness Check)"
        } else {
            _lblPageTitle.text = "Enroll Live ID"
        }
        
        if isForVerification {
            //For LiveID Verification
            _lblPageTitle.text = "Live ID Authentication"
        }
        startLiveIDScanning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - LiveID Scanning -
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
                    //3. Initialize LiveIDScannerHelper
                    if self.liveIdScannerHelper == nil {
                        self.liveIdScannerHelper = LiveIDScannerHelper.init(liveIdResponseDelegate: self)
                    }
                    //4. Start Scanning
                    self.liveIdScannerHelper?.startLiveIDScanning()
                }
            }
        }
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
    
    @IBAction func cancelTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to cancel the registration process?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.stopLiveIDScanning()
            self.goBack()
        }))
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
            self.view.makeToast("Live ID enrolled successfully", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
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
            if let onFinishCallback = self.onFinishCallback {
                onFinishCallback(true)
            }
            self.goBack()
        }
    }
    private func showErrorDialog(_ error: ErrorResponse?) {
        var title: String? = nil
        var msg: String? = nil
        if error?.code == NSURLErrorNotConnectedToInternet ||
            error?.code == CustomErrors.Network.OFFLINE.code {
            msg = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
            title = ErrorConfig.noInternet.title
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
    
}

// MARK: - LiveIDResponseDelegate -
extension LiveIDViewController: LiveIDResponseDelegate {
  
    func liveIdDidDetectErrorInScanning(error: ErrorResponse?) {
        //Check If licenene key not enabled
        if error?.code == CustomErrors.kSomeProblemWhileFaceFinding.code {
            self._lblInformation.text = "Camera sensor is blocked. Unblock sensor and continue..."
            Vibration.error.vibrate()
        }
    }
    
    func liveIdDetectionCompleted(_ liveIdImage: UIImage?, signatureToken: String?, error: ErrorResponse?) {
        
        if error?.code == CustomErrors.kScanCancelled.code {
            // Selfie scanner cancelled
            self.goBack()
        }
        
        if error?.code == CustomErrors.License.MODULE_NOT_ENABLED.code {
            let localizedMessage = "MODULE_NOT_ENABLED".localizedMessage(CustomErrors.License.MODULE_NOT_ENABLED.code)
            self.view.makeToast(localizedMessage,
                                duration: 3.0,
                                position: .center,
                                title: ErrorConfig.error.title, completion: {_ in
                self.goBack()
            })
            return
        }
        
        guard let face = liveIdImage, let signToken = signatureToken else {
            var errorMessage = error?.message ?? ""
            if let dict = error?.responseObj {
                errorMessage = "(" + "\(error?.code ?? 0)" + ")"  + (error?.message ?? "") + "\n"
                let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
                let decoded = String(data: jsonData, encoding: .utf8)!
                errorMessage += decoded
            } else {
                errorMessage = (error?.message ?? "") + "(" + "\(error?.code ?? 0)" + ")"  + "\n"
            }

            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {_ in
                self.goBack()
            }))
            self.present(alert, animated: true)
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
        
        Vibration.heavy.vibrate()
    }
    
    func readyForExpression(_ livenessFactor: LivenessFactorType) {
        DispatchQueue.main.async {
            self._lblInformation.isHidden = false
            self._lblInformation.text = ""
            Vibration.success.vibrate()
            switch livenessFactor {
            case .BLINK:
                self._lblInformation.text = DetectionMsg.blink
            case .SMILE:
                self._lblInformation.text = DetectionMsg.smile
            case .TURN_LEFT:
                self._lblInformation.text = DetectionMsg.left
            case .TURN_RIGHT:
                self._lblInformation.text = DetectionMsg.right
            case .NONE:
                return
            /*case .MOVE_UP:
                self._lblInformation.text = DetectionMsg.up
            case .MOVE_DOWN:
                self._lblInformation.text = DetectionMsg.down*/
            @unknown default:
                return
            }
            self.imgOverlay.tintColor = .green
        }

    }
    
    func faceLivenessCheckStarted() {
        isLoaderHidden = true
        self.view.makeToastActivity(.center)
    }
    
    func focusOnFaceChanged(isFocused: Bool?) {
        guard let inFocus = isFocused else {
            return
        }
        
        if !inFocus {
            DispatchQueue.main.async {
                self.imgOverlay.tintColor = .red
                self._lblInformation.text = "Out of focus !!!. Please try again."
                Vibration.oldSchool.vibrate()
            }
        } else {
            DispatchQueue.main.async {
                self.imgOverlay.tintColor = .green

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
        case .TURN_LEFT:
            factor = "Turned Left"
        case .TURN_RIGHT:
            factor = "Turned Right"
        case .NONE:
            factor = "Unknown"
       /* case .MOVE_UP:
            factor = "Moved Up"
        case .MOVE_DOWN:
            factor = "Moved Down"*/
        }
        
        DispatchQueue.main.async {
            self.imgOverlay.tintColor = .red
            self._lblInformation.text = "Wrong Expression: \(factor)"
            Vibration.oldSchool.vibrate()

        }
    }
}
