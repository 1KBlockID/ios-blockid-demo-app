//
//  PassportViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import AVFoundation
import BlockID
import Toast_Swift
import CoreNFC

class PassportViewController: UIViewController {

    private let expiryDays = 90
    private var dictPPT: [String : Any]?
    private var isWithNFC = false
    private let kPPTFailedMessage = "Passport failed to scan."
    private let kSessionExpiredOrTimeout = "This verification session is no longer available. You need to begin the journey again."

    private var rfidScannerHelper: RFIDScannerHelper?
    private var liveIdFace: String!
    private var proofedBy: String!
    private var sessionId: String!
    var storeId: String?

    @IBOutlet weak var _viewEPassportScan: UIView!
    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var imgLoader: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start loader spin
        self.rotateView(imgLoader)
        
        // Start PPT loading
        startPassportScanning()
    }
    
    private func startPassportScanning() {
        //1. Check for Camera Permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if !response {
                //2. Show Alert
                DispatchQueue.main.async {
                    self.alertForCameraAccess()
                }
            } else {
                DispatchQueue.main.async {
                    self.showDocumentScannerFor(.PPT, self.storeId, self)
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
    
    private func setPassport(withPPData ppt: [String : Any], isWithNFC: Bool, _ sessionId: String?) {
        var dict = ppt
        dict["category"] = RegisterDocCategory.Identity_Document.rawValue
        dict["type"] = RegisterDocType.PPT.rawValue
        dict["id"] = ppt["id"]
        
        if !BlockIDSDK.sharedInstance.isLiveIDRegisterd() {
            self.registerWithLiveID(dic: dict, sessionId)
        } else {
            self.registerWithOutLiveID(dic: dict, sessionId)
        }
    }
    
    private func registerWithLiveID(dic: [String: Any]?, _ sessionId: String?) {
        guard let imgB64Str = self.liveIdFace,
              let imgdata = Data(base64Encoded: imgB64Str,
                                 options: .ignoreUnknownCharacters),
              let img = UIImage(data: imgdata) else {
            return
        }
        
        let mobileDocumentId = "ppt_with_live_id_" + UUID().uuidString
        BlockIDSDK.sharedInstance.registerDocument(obj: dic ?? [:],
                                                   liveIdProofedBy: self.proofedBy,
                                                   faceImage: img,
                                                   mobileSessionId: sessionId,
                                                   mobileDocumentId: mobileDocumentId)
        { [self] (status, error) in
            DispatchQueue.main.async {
                if !status {
                    // FAILED
                    self.view.makeToast(error?.message, duration: 3.0, position: .center)
                    return
                }
                // SUCCESS
                var nfcTxt = ""
                if !self.isWithNFC {
                    nfcTxt = "RFID not scanned"
                }
                self.view.makeToast("Passport enrolled successfully. \(nfcTxt)",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Thank you!",
                                    completion: {_ in
                    self.goBack()
                })
            }
        }
    }
    
    private func registerWithOutLiveID(dic: [String: Any], _ sessionId: String?) {
        let mobileDocumentId = "ppt_" + UUID().uuidString
        BlockIDSDK.sharedInstance.registerDocument(obj: dic,
                                                   mobileSessionId: sessionId,
                                                   mobileDocumentId: mobileDocumentId) { [self] (status, error) in
            DispatchQueue.main.async {
                if !status {
                    // FAILED
                    self.view.makeToast(error?.message, duration: 3.0, position: .center)
                    return
                }
                // SUCCESS
                var nfcTxt = ""
                if !self.isWithNFC {
                    nfcTxt = "RFID not scanned"
                }
                self.view.makeToast("Passport enrolled successfully. \(nfcTxt)",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Thank you!",
                                    completion: {_ in
                    self.goBack()
                })
            }
        }
    }
    
    //Check for NFC Capability of the device
    private func isDeviceNFCCompatible() -> Bool? {
        if #available(iOS 11.0, *) {
           if NFCNDEFReaderSession.readingAvailable {
            // NFC available to use
            return true
           }
           else {
             // NFC not allowed to use
            return nil
           }
        } else {
          //iOS don't support NFC
            return false
        }
    }
    
    private func startRFIDScanWorkflow(withPPData ppt: [String : Any], _ sessionId: String?) {
        self.dictPPT = ppt
        if let isNFCCompatible = isDeviceNFCCompatible(), isNFCCompatible {
            //NOT NFC COMPATIBLE
            if !isNFCCompatible {
                //Cannot scan NFC, proceed with bio-data of PP
                self.setPassport(withPPData: ppt, isWithNFC: false, sessionId)
                return
            }
           
            self.showRFIDViewController(delegate: self)
            return
        }
        //NFC is Disabled
        self.showNFCDisableViewController(delegate: self)
    }
    
    private func handleScanErrorResponse(error: ErrorResponse, _ sessionId: String?) {
        let msg = "\(error.message) (Error code: \(error.code))"
        
        switch error.code {
        case CustomErrors.kPPRFIDUserCancelled.code:

            //About to Expire, Show Alert
            let alert = UIAlertController(title: "Warning!",
                                          message: "Do you want to cancel RFID Scan?",
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.setPassport(withPPData: self.dictPPT!, isWithNFC: false, sessionId)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
                self._viewEPassportScan.isHidden = false
                self.rfidScannerHelper?.startRFIDScanning()
            }))
            self.present(alert, animated: true)
            return
            
        case CustomErrors.kPPRFIDTimeout.code:
            self.view.makeToast("Scan Again",
                                duration: 3.0,
                                position: .center,
                                title: "Timeout",
                                completion: {_ in
                self._viewEPassportScan.isHidden = false
                self.rfidScannerHelper?.startRFIDScanning()
            })
            return
            
        case CustomErrors.License.MODULE_NOT_ENABLED.code:
            let localizedMessage = "MODULE_NOT_ENABLED".localizedMessage(CustomErrors.License.MODULE_NOT_ENABLED.code)
            self.view.makeToast(localizedMessage,
                                duration: 3.0,
                                position: .center,
                                title: "Error",
                                completion: {_ in
                self.goBack()
            })
            return
            
        default:
            self.view.makeToast(msg,
                                duration: 3.0,
                                position: .center,
                                title: "Error",
                                completion: {_ in
                self.goBack()
            })
            return
        }
    }
}

// MARK: - DocumentSessionScanDelegate -
extension PassportViewController: DocumentScanDelegate {
    
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
                                      message: error?.message ?? kPPTFailedMessage)
            return
        }
        
        guard let documentObject = document,
              !documentObject.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
            return
        }
        guard let dictDocObject = CommonFunctions.jsonStringToDic(from: documentObject) else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
            return
        }
        
        guard let responseStatus = dictDocObject["responseStatus"] as? String,
              !responseStatus.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
            return
        }
        
        let failedStatuses: Set<String> = ["FAILED", "EXPIRED", "ABANDONED"]
        if failedStatuses.contains(responseStatus.uppercased()) {
            var title = "Error"
            var msg = ""
            switch responseStatus.uppercased() {
            case "FAILED":
                msg = kPPTFailedMessage
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
                                      message: kPPTFailedMessage)
            return
        }
        guard var dictPPTObject = dictDocObject["ppt_object"] as? [String: Any] else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
            return
        }
        guard let proof_jwt = dictPPTObject["proof_jwt"] as? String,
              !proof_jwt.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
            return
        }
        
        if let liveIdObj = dictDocObject["liveid_object"] as? [String: Any] {
            self.liveIdFace = liveIdObj["face"] as? String
            self.proofedBy = liveIdObj["proofedBy"] as? String
        }
        self.sessionId = sessionID
        dictPPTObject["proof"] = proof_jwt
        dictPPTObject["certificate_token"] = token
        self.startRFIDScanWorkflow(withPPData: dictPPTObject, sessionID)
    }
    
    private func showAlertAndMoveBack(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.goBack()
        }))
        present(alert, animated: true)
    }
}

extension PassportViewController: EPassportChipScanViewControllerDelegate {
    func onScan() {
        self._viewEPassportScan.isHidden = false
        self.rfidScannerHelper = RFIDScannerHelper(rfidResponseDelegate: self,
                                                   ppObject: self.dictPPT ?? [:],
                                                   expiryGracePeriod: self.expiryDays)
        self.rfidScannerHelper?.startRFIDScanning()
    }
    
    func onSkip() {
        self.setPassport(withPPData: dictPPT!, isWithNFC: false, self.sessionId)
    }
}
extension PassportViewController: NFCDisabledViewControllerDelegate {
    func cancelRFID() {
        self.setPassport(withPPData: dictPPT!, isWithNFC: false, self.sessionId)
    }
}

extension PassportViewController: RFIDResponseDelegate {
    func rfidScanCompleted(withPassport docDic: [String : Any]?, error: ErrorResponse?) {
        assert(Thread.isMainThread, "call me on main thread")
        
        //Check for errors
        //  EXPIRED || INVALID || TIMEOUT || USER_CANCEL
        if error?.code == CustomErrors.kPPExpired.code ||
            error?.code == CustomErrors.kInvalidPP.code ||
            error?.code == CustomErrors.kPPRFIDTimeout.code ||
            error?.code == CustomErrors.kPPRFIDUserCancelled.code {
            
            guard let err = error else {
                return
            }
            self.handleScanErrorResponse(error: err, self.sessionId)
            
            return
        }
        
        guard let ppt = docDic else {
            guard let err = error else {
                return
            }
            self.handleScanErrorResponse(error: err, self.sessionId)
            return
        }
        
        //Check if Not to Expiring Soon
        if error?.code == CustomErrors.kPPAboutToExpire.code {
            //About to Expire, Show Alert
            let msg = "\(error?.message ?? CustomErrors.kSomethingWentWrong.msg) (Error code: \(error?.code ?? CustomErrors.kSomethingWentWrong.code))"
            
            //About to Expire, Show Alert
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.setPassport(withPPData: ppt, isWithNFC: true, self.sessionId)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
                
                self.rfidScannerHelper?.stopRFIDScanning()
                self.goBack()
            }))
            self.present(alert, animated: true)
            return
        }
        self.setPassport(withPPData: ppt, isWithNFC: true, self.sessionId)
    }
}
