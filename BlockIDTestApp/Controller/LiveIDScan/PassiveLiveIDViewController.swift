//
//  PassiveLiveIDViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering on 03/07/23.
//

import UIKit
import AVFoundation
import BlockID

class PassiveLiveIDViewController: UIViewController {
    
    // MARK: - Private properties -
    private var liveIdScannerHelper: LiveIDScannerHelper?
    
    // MARK: - View life cycle -
    override func viewDidLoad() {
        startLiveIDScanning()
    }
    
    
    // MARK: - Private methods -
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
    
    // navigation to previous screen...
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
    
    // register liveID...
    /// - Parameters
    ///  - face: liveID image from liveID scanner object
    private func registerLiveID(withPhoto face: UIImage, token: String) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.setLiveID(liveIdImage: face,
                                            liveIdProofedBy: "",
                                            sigToken: token) { [self] (status, error) in
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
    
    // stop liveID scanning...
    private func stopLiveIDScanning() {
        self.liveIdScannerHelper?.stopLiveIDScanning()
    }

}


// MARK: - Extension -
extension PassiveLiveIDViewController: LiveIDResponseDelegate {

    func liveIdDetectionCompleted(_ liveIdImage: UIImage?, signatureToken: String?, error: ErrorResponse?) {
        
        // check for error...
        if error?.code == CustomErrors.kScanCancelled.code {
            // Selfie scanner cancelled
            self.goBack()
        }
        
        // check for error...
        if error?.code == CustomErrors.License.MODULE_NOT_ENABLED.code {
            let localizedMessage = "MODULE_NOT_ENABLED".localizedMessage(CustomErrors.License.MODULE_NOT_ENABLED.code)
            self.view.makeToast(localizedMessage,
                                duration: 3.0,
                                position: .center,
                                title: ErrorConfig.error.title, completion: {_ in
                // go back to previous screen...
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
            
            let alert = UIAlertController(title: "Error",
                                          message: errorMessage,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: .default, handler: {_ in
                // go back to previous screen...
                self.goBack()
            }))
            self.present(alert, animated: true)
            return
        }
        
        // register LiveID
        self.registerLiveID(withPhoto: face, token: signToken)
    }
}
