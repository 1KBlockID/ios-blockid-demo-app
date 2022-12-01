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
    
    @IBOutlet private weak var viewActivityIndicator: UIView!
    @IBOutlet private weak var activityIndicator: CustomActivityIndicator!
    @IBOutlet private weak var lblActivityIndicator: UILabel!
    
    // MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startLiveIDScanning()
    }
}

// MARK: - Private Methods -
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
                                guard let imgdataB64 = liveidDataDic[VerifyDocumentHelper.shared.kLiveId] as? String else { return }
                                guard let imgdata = Data(base64Encoded: imgdataB64,
                                                         options: .ignoreUnknownCharacters),
                                      let photo = UIImage(data: imgdata) else { return }
                                // Verify LiveID
                                self.verifyLiveID(withPhoto: photo,
                                                  token: nil)
                            } else {
                                // Set LiveID
                                guard let imgdataB64 = liveidDataDic["liveId"] as? String else { return }
                                guard let imgdata = Data(base64Encoded: imgdataB64,
                                                         options: .ignoreUnknownCharacters),
                                      let photo = UIImage(data: imgdata) else { return }
                                self.setLiveID(withPhoto: photo, token: nil)
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
        DispatchQueue.main.async {
            self.lblActivityIndicator.text = "VERIFING_LIVEID".localizedMessage(0)
            self.viewActivityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        BlockIDSDK.sharedInstance.verifyLiveID(image: photo,
                                               sigToken: token) { (status, error) in
            self.activityIndicator.stopAnimating()
            if !status {
                // If verification is for User Consent
                if self.isForConsent {
                    self.attemptCounts += 1
                    if self.attemptCounts == 3 {
                        self.attemptCounts = 0
                        // Failed 3 attempts
                        // Finish Process with false status
                        self.lblActivityIndicator.text = nil
                        self.view.makeToast("LIVEID_VERIFICATION_FAILED".localizedMessage(0),
                                            duration: 3.0,
                                            position: .center,
                                            title: "Error",
                                            completion: {_ in
                            if let onFinishCallback = self.onFinishCallback {
                                onFinishCallback(true)
                            }
                            self.goBack()
                        })
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
            self.view.makeToast("LIVEID_VERIFIED".localizedMessage(0),
                                duration: 3.0,
                                position: .center,
                                title: "Thank you!",
                                completion: {_ in
                if let onFinishCallback = self.onFinishCallback {
                    onFinishCallback(true)
                }
                self.goBack()
            })
            
            
        }
    }
    
    private func checkLiveness(liveidImgDic: [String: Any]) {
        DispatchQueue.main.async {
            self.lblActivityIndicator.text = "VALIDATING_LIVENESS".localizedMessage(0)
            self.viewActivityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        var liveidDataDic = liveidImgDic
        liveidDataDic[VerifyDocumentHelper.shared.kID] = BlockIDSDK.sharedInstance.getDID() + ".liveid"
        liveidDataDic[VerifyDocumentHelper.shared.kType] = VerifyDocumentHelper.shared.kTypeLiveId
        guard let imgdataB64 = liveidDataDic[VerifyDocumentHelper.shared.kLiveId] as? String else { return }
        VerifyDocumentHelper.shared.checkLiveness(liveIDBase64: imgdataB64)
        { status, error in
            if !status {
                self.activityIndicator.stopAnimating()
                self.showErrorDialog(error)
            } else {
                guard let imgdata = Data(base64Encoded: imgdataB64,
                                         options: .ignoreUnknownCharacters),
                      let img = UIImage(data: imgdata) else { return }
                self.setLiveID(withPhoto: img, token: nil)
            }
        }
    }
    
    private func setLiveID(withPhoto photo: UIImage, token: String?) {
        DispatchQueue.main.async {
            self.viewActivityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.lblActivityIndicator.text = "REGISTER_DATA".localizedMessage(0)
        }
        
        BlockIDSDK.sharedInstance.setLiveID(liveIdImage: photo,
                                            liveIdProofedBy: "blockid",
                                            sigToken: token) { [self] (status, error) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
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
                self.view.makeToast("LIVEID_ENROLLED".localizedMessage(0),
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
