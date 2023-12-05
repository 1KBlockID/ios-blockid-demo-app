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
    private var rfidScannerHelper: RFIDScannerHelper?
    
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
                    self.showDocumentScannerFor(.PPT, self)
                }
            }
        }
        
    }
    
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setPassport(withPPData ppt: [String : Any], isWithNFC: Bool) {
        var dict = ppt
        dict["category"] = RegisterDocCategory.Identity_Document.rawValue
        dict["type"] = RegisterDocType.PPT.rawValue
        dict["id"] = ppt["id"]
        
        BlockIDSDK.sharedInstance.registerDocument(obj: dict) { [self] (status, error) in
            DispatchQueue.main.async {
                if !status {
                    if error?.code == CustomErrors.kLiveIDMandatory.code {
                        DocumentStore.sharedInstance.setData(documentData: dict)
                        self.goBack()
                        self.showLiveIDView()
                        return
                    }
                    // FAILED
                    self.view.makeToast(error?.message, duration: 3.0, position: .center)
                    return
                }
                // SUCCESS
                var nfcTxt = ""
                if !isWithNFC {
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
    
    private func startRFIDScanWorkflow(withPPData ppt: [String : Any]) {
        self.dictPPT = ppt
        if let isNFCCompatible = isDeviceNFCCompatible(), isNFCCompatible {
            //NOT NFC COMPATIBLE
            if !isNFCCompatible {
                //Cannot scan NFC, proceed with bio-data of PP
                self.setPassport(withPPData: ppt, isWithNFC: false)
                return
            }
           
            self.showRFIDViewController(delegate: self)
            return
        }
        //NFC is Disabled
        self.showNFCDisableViewController(delegate: self)
    }
    
    private func handleScanErrorResponse(error: ErrorResponse) {
        let msg = "\(error.message) (Error code: \(error.code))"
        
        switch error.code {
        case CustomErrors.kPPRFIDUserCancelled.code:

            //About to Expire, Show Alert
            let alert = UIAlertController(title: "Warning!",
                                          message: "Do you want to cancel RFID Scan?",
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.setPassport(withPPData: self.dictPPT!, isWithNFC: false)
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
    
    func onDocumentScanResponse(status: Bool, document: String?, error: ErrorResponse?) {
        if error?.code == CustomErrors.kUnauthorizedAccess.code {
            self.showAppLogin()
        }
        
        if error?.code == CustomErrors.License.MODULE_NOT_ENABLED.code {
            let localizedMessage = "MODULE_NOT_ENABLED".localizedMessage(CustomErrors.License.MODULE_NOT_ENABLED.code)
            self.showAlertAndMoveBack(title: "Error",
                                      message: localizedMessage)
            return
        }
        
        if error?.code == CustomErrors.DocumentScanner.CANCELED.code { // Cancelled
            self.goBack()
        }
        
        if error?.code == CustomErrors.DocumentScanner.TIMEOUT.code {
            self.showAlertAndMoveBack(title: "Error",
                                      message: "Scanning time exceeded. To continue, please restart the scanning process.")
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
        if responseStatus.uppercased() == "FAILED" {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
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
        
        dictPPTObject["proof"] = proof_jwt
        dictPPTObject["certificate_token"] = token
        self.startRFIDScanWorkflow(withPPData: dictPPTObject)
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
        self.setPassport(withPPData: dictPPT!, isWithNFC: false)
    }
}
extension PassportViewController: NFCDisabledViewControllerDelegate {
    func cancelRFID() {
        self.setPassport(withPPData: dictPPT!, isWithNFC: false)
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
            self.handleScanErrorResponse(error: err)
            
            return
        }
        
        guard let ppt = docDic else {
            guard let err = error else {
                return
            }
            self.handleScanErrorResponse(error: err)
            return
        }
        
        //Check if Not to Expiring Soon
        if error?.code == CustomErrors.kPPAboutToExpire.code {
            //About to Expire, Show Alert
            let msg = "\(error?.message ?? CustomErrors.kSomethingWentWrong.msg) (Error code: \(error?.code ?? CustomErrors.kSomethingWentWrong.code))"
            
            //About to Expire, Show Alert
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.setPassport(withPPData: ppt, isWithNFC: true)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
                
                self.rfidScannerHelper?.stopRFIDScanning()
                self.goBack()
            }))
            self.present(alert, animated: true)
            return
        }
        setPassport(withPPData: ppt, isWithNFC: true)
    }
}
