//
//  NationalIDViewController.swift.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import AVFoundation
import BlockID
import Toast_Swift
  
class NationalIDViewController: UIViewController {

    private let kIDCardFailedMessage = "National ID failed to scan."
    private let kSessionExpiredOrTimeout = "This verification session is no longer available. You need to begin the journey again."

    private var liveIdFace: String!
    private var proofedBy: String!

    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var imgLoader: UIImageView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start loader spin
        self.rotateView(imgLoader)
        
        // Start ID CARD loading
        startNationalIDScanning()
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
    
    private func startNationalIDScanning() {
        //1. Check for Camera Permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if !response {
                //2. Show Alert
                DispatchQueue.main.async {
                    self.alertForCameraAccess()
                }
            } else {
                DispatchQueue.main.async {
                    self.showDocumentScannerFor(.IDCARD, self)
                }
            }
        }
        
    }

    private func setNationaID(withNIDData nid: [String : Any], _ sessionId: String?) {
        var dic = nid
        dic["category"] = RegisterDocCategory.Identity_Document.rawValue
        dic["type"] = RegisterDocType.NATIONAL_ID.rawValue
        dic["id"] = nid["id"] as! String
        
        if !BlockIDSDK.sharedInstance.isLiveIDRegisterd() {
            self.registerWithLiveID(dic: dic, sessionId)
        } else {
            self.registerWithOutLiveID(dic: dic, sessionId)
        }
    }
    
    private func registerWithLiveID(dic: [String: Any], _ sessionId: String?) {
        guard let imgB64Str = self.liveIdFace,
              let imgdata = Data(base64Encoded: imgB64Str,
                                 options: .ignoreUnknownCharacters),
              let img = UIImage(data: imgdata) else {
            return
        }
        
        let mobileDocumentId = "nationalid_with_live_id_" + UUID().uuidString
        BlockIDSDK.sharedInstance.registerDocument(obj: dic,
                                                   liveIdProofedBy: self.proofedBy,
                                                   faceImage: img,
                                                   mobileSessionId: sessionId,
                                                   mobileDocumentId: mobileDocumentId)
        { [self] (status, error) in
            DispatchQueue.main.async {
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
                self.view.makeToast("National ID enrolled successfully.",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Thank you!", completion: {_ in
                    self.goBack()
                })
            }
        }
    }
    
    private func registerWithOutLiveID(dic: [String: Any], _ sessionId: String?) {
        let mobileDocumentId = "nationalid_" + UUID().uuidString
        BlockIDSDK.sharedInstance.registerDocument(obj: dic,
                                                   mobileSessionId: sessionId,
                                                   mobileDocumentId: mobileDocumentId) { [self] (status, error) in
            DispatchQueue.main.async {
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
                self.view.makeToast("National ID enrolled successfully.",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Thank you!", completion: {_ in
                    self.goBack()
                })
            }
        }
    }
}

// MARK: - DocumentSessionScanDelegate -
extension NationalIDViewController: DocumentScanDelegate {
    
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
            
            self.showAlertAndMoveBack(title: "Error",
                                      message: error?.message ?? kIDCardFailedMessage)
            return
        }
        
        guard let documentObject = document,
              !documentObject.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        guard let dictDocObject = CommonFunctions.jsonStringToDic(from: documentObject) else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        guard let responseStatus = dictDocObject["responseStatus"] as? String,
              !responseStatus.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        
        let failedStatuses: Set<String> = ["FAILED", "EXPIRED", "ABANDONED"]
        if failedStatuses.contains(responseStatus.uppercased()) {
            var title = "Error"
            var msg = ""
            switch responseStatus.uppercased() {
            case "FAILED":
                msg = kIDCardFailedMessage
            case "EXPIRED":
                title = "Session Expired"
                msg = kSessionExpiredOrTimeout
            case "ABANDONED":
                title = "Scanning Timeout"
                msg = kSessionExpiredOrTimeout
            default:
                debugPrint("unknown status")
            }
            self.showAlertAndMoveBack(title: title,
                                      message: msg)
            return
        }
        
        guard let token = dictDocObject["token"] as? String,
              !token.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        guard var dictIdcardObject = dictDocObject["idcard_object"] as? [String: Any] else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        guard let proof_jwt = dictIdcardObject["proof_jwt"] as? String,
              !proof_jwt.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        
        if let liveIdObj = dictDocObject["liveid_object"] as? [String: Any] {
            self.liveIdFace = liveIdObj["face"] as? String
            self.proofedBy = liveIdObj["proofedBy"] as? String
        }

        dictIdcardObject["proof"] = proof_jwt
        dictIdcardObject["certificate_token"] = token
        self.setNationaID(withNIDData: dictIdcardObject, sessionID)
    }

    private func showAlertAndMoveBack(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.goBack()
        }))
        self.present(alert, animated: true)
    }
}

