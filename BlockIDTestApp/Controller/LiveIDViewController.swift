//
//  LiveIDViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import UIKit
import AVFoundation
import BlockID

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
    
    // MARK: - Properties -
    var isForVerification: Bool = false
    var isForConsent: Bool = false
       
    // MARK: - Private properties -
    private var liveIdScannerHelper: LiveIDScannerHelper?
    private var attemptCounts = 0
    private var imgOverlay: UIImageView!
    
    // MARK: - Completion handler -
    var onFinishCallback: ((_ status: Bool) -> Void)?

    // MARK: - IBOutlets -
    @IBOutlet private weak var _viewBG: UIView!
    @IBOutlet private weak var _viewLiveIDScan: BIDScannerView!
    @IBOutlet private weak var _imgOverlay: UIImageView!
    @IBOutlet private weak var _lblInformation: UILabel!
    @IBOutlet private weak var _lblPageTitle: UILabel!
    
    // MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isForVerification {
            //For LiveID Verification
            _lblPageTitle.text = "Live ID Authentication"
        }
        startLiveIDScanning()
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
                    // Initialize LiveIDScannerHelper
                    if self.liveIdScannerHelper == nil {
                        self.liveIdScannerHelper = LiveIDScannerHelper.init(bidScannerView: self._viewLiveIDScan,
                                                                            overlayFrame: self._imgOverlay.frame,
                                                                            liveIdResponseDelegate: self)
                    }
                    //4. Start Scanning
                    self.liveIdScannerHelper?.startLiveIDScanning(dvcID: AppConsant.dvcID)
                }
            }
        }
    }
        
    // go to previous screen..
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
    
    // MARK: - IBActions -
    @IBAction func cancelTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Cancellation warning!",
                                      message: "Do you want to cancel the registration process?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No",
                                      style: .default,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .default, handler: {_ in
            self.stopLiveIDScanning()
            self.goBack()
        }))
        self.present(alert, animated: true)
        return
    }
    
    // register liveID -
    /// - Parameters
    /// - face: liveID image from liveID scanner object
    private func setLiveID(withPhoto face: UIImage, token: String, livenessResult: String?) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.setLiveID(liveIdImage: face,
                                            liveIdProofedBy: "",
                                            sigToken: token, 
                                            livenessResult: livenessResult) { [self] (status, error) in
            self.view.hideToastActivity()
            if !status {
                // FAILED
                self.view.makeToast(error?.message,
                                    duration: 3.0,
                                    position: .center,
                                    title: "Error!", completion: {_ in
                    self.goBack()
                })
                return
            }
            // SUCCESS
            self.stopLiveIDScanning()
            self.view.makeToast("Live ID enrolled successfully",
                                duration: 3.0,
                                position: .center,
                                title: "Thank you!", completion: {_ in
                self.goBack()
            })

        }
    }
    
    // register liveID with doc
    /// - Parameters
    /// - face: liveID image from liveID scanner object
    private func registerLiveIDWithDocument(withPhoto face: UIImage, token: String) {
        self.view.makeToastActivity(.center)
        let documentData = DocumentStore.sharedInstance.getDocumentStoreData()
        guard let obj = documentData.documentData else { return  }
        
        BlockIDSDK.sharedInstance.registerDocument(obj: obj,
                                                   liveIdProofedBy: "",
                                                   faceImage: face,
                                                   liveIDSignToken: token) { [self] (status, error) in
            self.view.hideToastActivity()
            DocumentStore.sharedInstance.clearData()
            // SUCCESS
            self.stopLiveIDScanning()
            if !status {
                // FAILED
                self.view.makeToast(error?.message,
                                    duration: 3.0,
                                    position: .center,
                                    title: "Error!", completion: {_ in
                    self.goBack()
                })
                return
            }

            self.view.makeToast("Document enrolled successfully",
                                duration: 3.0,
                                position: .center,
                                title: "Thank you!",
                                completion: {_ in
                self.goBack()
            })

        }
    }
    
    // verify liveID
    /// - Parameters
    /// - face: liveID image from liveID scanner object
    private func verifyLiveID(withPhoto photo: UIImage, token: String,
                              livenessResult: String?) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.verifyLiveID(image: photo,
                                               sigToken: token, 
                                               livenessResult: livenessResult) { (status, error) in
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
    
    // show error dialog...
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
        self.view.makeToast(msg,
                            duration: 3.0,
                            position: .center,
                            title: title,
                            completion: {_ in
            self.goBack()
        })
    }
    
    // stop liveID scanning...
    private func stopLiveIDScanning() {
        self.liveIdScannerHelper?.stopLiveIDScanning()
    }
    
}

// MARK: - LiveIDResponseDelegate -
extension LiveIDViewController: LiveIDResponseDelegate {
  
    func liveIdDidDetectErrorInScanning(error: ErrorResponse?) {
        // check error when camera sensor is blocked.
        if error?.code == CustomErrors.kSomeProblemWhileFaceFinding.code {
            self._lblInformation.text = "Camera sensor is blocked. Unblock sensor and continue."
            Vibration.error.vibrate()
        }
    }
    
    func liveIdDetectionCompleted(_ liveIdImage: UIImage?,
                                  signatureToken: String?,
                                  livenessResult: String?,
                                  error: ErrorResponse?) {
        // check for error...
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
        
        // check for error...
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
            self.verifyLiveID(withPhoto: face, token: signToken, livenessResult: livenessResult)
        } else {
            // Set LiveID
            if DocumentStore.sharedInstance.hasData() {
                self.registerLiveIDWithDocument(withPhoto: face, token: signToken)
                return
            }
            self.setLiveID(withPhoto: face, token: signToken, livenessResult: livenessResult)

        }
        
        Vibration.heavy.vibrate()
    }
    
    func faceLivenessCheckStarted() {
        self.view.makeToastActivity(.center)
    }
    
    // show error when face is out of focus
    func focusOnFaceChanged(isFocused: Bool?, message: String?) {
        guard let inFocus = isFocused else {
            return
        }
                
        self._lblInformation.text = message
        self._lblInformation.isHidden = inFocus
        if !inFocus {
            DispatchQueue.main.async {
                self._imgOverlay.tintColor = .red
                Vibration.oldSchool.vibrate()
            }
        } else {
            DispatchQueue.main.async {
                self._imgOverlay.tintColor = .green
            }
        }
    }
}
