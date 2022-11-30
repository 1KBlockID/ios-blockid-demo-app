//
//  SelfieScannerViewController.swift
//  
//
//  Created by Prasanna gupta on 30/11/22.
//

import UIKit
import AVFoundation
import BlockIDSDK

class SelfieScannerViewController: UIViewController {
    var isForVerification: Bool = false
    var isForConsent: Bool = false
    private var attemptCounts = 0
    var onFinishCallback: ((_ status: Bool) -> Void)?
    
    // MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startLiveIDScanning()
    }
}

// MARK: - Private function -
extension SelfieScannerViewController {
    private func goBack() {
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController.isKind(of: EnrollMentViewController.self) {
                    self.navigationController?.popToViewController(viewController,
                                                                   animated: true)
                }
            }
            return
        }
        self.navigationController?.popViewController(animated: true)
    }

    private func startLiveIDScanning() {
        // Check for Camera Permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if !response {
                // Show Alert for Camera Access
                DispatchQueue.main.async {
                    self.alertForCameraAccess()
                }
            } else {
                DispatchQueue.main.async {
                        SelfieScannerHelper.shared.startLiveIDScan(from: self) { status, data, _ in
                            if status {
                                guard let liveidDataDic = data else { return }
                                if self.isForVerification {
                                    guard let imgdataB64 = liveidDataDic["liveId"] as? String else { return }
                                    guard let imgdata = Data(base64Encoded: imgdataB64,
                                                             options: .ignoreUnknownCharacters),
                                          let photo = UIImage(data: imgdata) else { return }
                                    // Verify LiveID
                                    self.verifyLiveID(withPhoto: photo, token: nil)
                                } else {
                                    // Set LiveID
                                    self.checkLiveness(liveidImgDic: liveidDataDic)
                                }
                            } else {
                                self.goBack()
                            }
                        }
                }
            }
        }
    }
    
    private func verifyLiveID(withPhoto photo: UIImage, token: String? = nil) {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.verifyLiveID(image: photo, sigToken: token) { (status, error) in
            self.view.hideToastActivity()
            if !status {
                // If verification is for User Consent
                if self.isForConsent {
                    self.attemptCounts += 1
                    debugPrint("LiveID: Current attempts = \(self.attemptCounts)")
                    if self.attemptCounts == 3 {
                        self.attemptCounts = 0
                        // Failed 3 attempts
                        // Finish Process with false status
                        if let onFinishCallback = self.onFinishCallback {
                            onFinishCallback(true)
                        }
                        self.goBack()
                        return
                    }
                    self.startLiveIDScanning()
                    return
                }
                // Verification failed, show error
                self.showErrorDialog(error)
                return
            }
            //Verification successful
            if let onFinishCallback = self.onFinishCallback {
                onFinishCallback(true)
            }
        }
    }
    
    private func checkLiveness(liveidImgDic: [String: Any]) {
        self.view.makeToastActivity(.center)
        var liveidDataDic = liveidImgDic
        liveidDataDic["id"] = BlockIDSDK.sharedInstance.getDID() + ".liveid"
        liveidDataDic["type"] = "liveid"

        BlockIDSDK.sharedInstance.verifyDocument(dic: liveidDataDic,
                                                 verifications: ["face_liveness"])
        { [weak self] (status, dataDic, error) in
            if !status {
                // Verification failed
                DispatchQueue.main.async {
                    self?.view.hideToastActivity()
                    self?.view.makeToast(error?.message,
                                        duration: 3.0,
                                        position: .center,
                                        title: "Error!",
                                        completion: {_ in
                        self?.goBack()
                    })
                    return
                }
            } else {
                if let dataDict = dataDic,
                    let certifications = dataDict["certifications"] as? [[String: Any]] {
                    if let isVerified = certifications[0]["verified"] as? Bool, isVerified {

                        guard let imgdataB64 = liveidDataDic["liveId"] as? String else { return }

                        guard let imgdata = Data(base64Encoded: imgdataB64,
                                                 options: .ignoreUnknownCharacters),
                              let img = UIImage(data: imgdata) else { return }

                        self?.setLiveID(withPhoto: img, token: nil)
                    } else {
                        let errorVerificationFailed = ErrorResponse(code: CustomErrors.kFaceLivenessCheckFailed.code,
                                                                    msg: CustomErrors.kFaceLivenessCheckFailed.msg)
                        // Verification failed
                        DispatchQueue.main.async {
                            self?.view.hideToastActivity()
                            self?.view.makeToast(errorVerificationFailed.message,
                                                duration: 3.0,
                                                position: .center,
                                                title: "Error!",
                                                completion: {_ in
                                self?.goBack()
                            })
                            return
                        }
                    }
                }
            }
        }
    }
    
    private func setLiveID(withPhoto photo: UIImage, token: String?) {
        DispatchQueue.main.async {
            self.view.makeToastActivity(.center)
        }
        
        BlockIDSDK.sharedInstance.setLiveID(liveIdImage: photo,
                                            liveIdProofedBy: "blockid",
                                            sigToken: token) { [self] (status, error) in
            DispatchQueue.main.async {
                self.view.hideToastActivity()
                if !status {
                    // FAILED
                    self.view.makeToast(error?.message,
                                        duration: 3.0,
                                        position: .center,
                                        title: "Error!",
                                        completion: {_ in
                        self.goBack()
                    })
                    return
                }
                // SUCCESS
                self.view.makeToast("Live ID enrolled successfully",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Thank you!",
                                    completion: {_ in
                    self.goBack()
                })
            }
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
        self.view.makeToast(msg, duration: 3.0,
                            position: .center,
                            title: title, completion: {_ in
            self.goBack()
        })
    }
}
