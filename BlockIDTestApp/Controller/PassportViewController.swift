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

    private var ppScannerHelper: PassportScanHelper?
    private let expiryDays = 90
    private var _scanLine: CAShapeLayer!
    private var _token = ""
    private var pp: [String : Any]?
    private var isWithNFC = false
    private var registrationCalled = false
    private let kPPTFailedMessage = "Passport failed to scan."
    
    @IBOutlet private weak var _viewBG: UIView!
    @IBOutlet private weak var _imgOverlay: UIImageView!
    @IBOutlet private weak var _lblScanInfoTxt: UILabel!
    @IBOutlet weak var _viewEPassportScan: UIView!
    @IBOutlet weak var _viewScanner: BIDScannerView!
    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var imgLoader: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start loader spin
        self.rotateView(imgLoader)
        // Start PPT loading
        startPassportScanning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint("***** viewWillAppear", self.description)
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
    
    // MARK:
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func cancelClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to cancel the registration process?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.ppScannerHelper?.stopPassportScanning()
            self.goBack()
        }))
        self.present(alert, animated: true)
        return
    }
    
    private func setPassport(withPPDat pp: [String : Any], token: String, isWithNFC: Bool) {
        if registrationCalled {
            return
        }
        registrationCalled = true
        var dic = pp
        dic["category"] = RegisterDocCategory.Identity_Document.rawValue
        dic["type"] = RegisterDocType.PPT.rawValue
        dic["id"] = pp["id"]
        
        BlockIDSDK.sharedInstance.registerDocument(obj: dic, sigToken: token) { [self] (status, error) in
            DispatchQueue.main.async {
                if !status {
                    
                    if error?.code == CustomErrors.kLiveIDMandatory.code {
                        DocumentStore.sharedInstance.setData(documentData: dic, token: token)
                        self.goBack()
                        self.showLiveIDView()
                        return
                    }
                    // FAILED
                    self.view.makeToast(error?.message, duration: 3.0, position: .center)
                    return
                }
                // SUCCESS
                self.ppScannerHelper?.stopPassportScanning()
                var nfcTxt = ""
                if !isWithNFC {
                    nfcTxt = "RFID not scanned"
                }
                self.view.makeToast("Passport enrolled successfully. \(nfcTxt)", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
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
    
    private func startRFIDScanWorkflow(withPPDat pp: [String : Any], token: String) {
        self._token = token
        self.pp = pp
        if let isNFCCompatible = isDeviceNFCCompatible(), isNFCCompatible {
            //NOT NFC COMPATIBLE
            if !isNFCCompatible {
                //Cannot scan NFC, proceed with bio-data of PP
                self.setPassport(withPPDat: pp, token: token, isWithNFC: false)
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
            let alert = UIAlertController(title: "Warning!", message: "Do you want to cancel RFID Scan?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.setPassport(withPPDat: self.pp!, token: self._token, isWithNFC: false)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
                self._viewEPassportScan.isHidden = false
                self.ppScannerHelper?.startRFIDScanning()
            }))
            self.present(alert, animated: true)
            return
            
        case CustomErrors.kPPRFIDTimeout.code:
            self.view.makeToast("Scan Again", duration: 3.0, position: .center, title: "Timeout", completion: {_ in
                self._viewEPassportScan.isHidden = false
                self.ppScannerHelper?.startRFIDScanning()
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
    
    private func scanCompleteUIUpdates() {
        self._lblScanInfoTxt.text = "Scan Complete"
        _scanLine.removeAllAnimations()
    }

}

// MARK: - DocumentSessionScanDelegate -
extension PassportViewController: DocumentScanDelegate {
    
    func onDocumentScanResponse(status: Bool, document: String?, error: ErrorResponse?) {
        debugPrint("???????? onDocumentScanResponse", error?.message)
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
        
        guard let pptObject = document else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
           return
        }
        guard let dictDocObject = CommonFunctions.jsonStringToDic(from: pptObject) else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
            return
        }
        debugPrint(dictDocObject)
        guard let responseStatus = dictDocObject["responseStatus"] as? String else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
           return
        }
        if responseStatus == "FAILED" {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
          return
        }
        guard let token = dictDocObject["token"] as? String, !token.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
            return
        }
        guard var dictPPTObject = dictDocObject["idcard_object"] as? [String: Any] else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
           return
        }
        guard let proof_jwt = dictPPTObject["proof_jwt"] as? String, !proof_jwt.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kPPTFailedMessage)
            return
        }
        
        dictPPTObject["proof"] = proof_jwt
        dictPPTObject["certificate_token"] = token
        self.setPassport(withPPDat: dictPPTObject,
                         token: "",
                         isWithNFC: self.isWithNFC)
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
        self.ppScannerHelper?.startRFIDScanning()
    }
    
    func onSkip() {
        self.setPassport(withPPDat: pp!, token: self._token, isWithNFC: false)
    }
}
extension PassportViewController: NFCDisabledViewControllerDelegate {
    func cancelRFID() {
        self.setPassport(withPPDat: pp!, token: self._token, isWithNFC: false)
    }
}
