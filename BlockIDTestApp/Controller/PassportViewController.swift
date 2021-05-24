//
//  PassportViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import AVFoundation
import BlockIDSDK
import Toast_Swift
import CoreNFC

class PassportViewController: UIViewController {

    private var ppScannerHelper: PassportScanHelper?
    private let selectedMode: ScanningMode = .SCAN_LIVE
    private let expiryDays = 90
    private var _scanLine: CAShapeLayer!
    private var _token = ""
    private var pp: BIDPassport?
    private var isWithNFC = false
    private var _viewLiveIDScan  =  BIDScannerView()
    
    @IBOutlet private weak var _viewBG: UIView!
    @IBOutlet private weak var _imgOverlay: UIImageView!
    @IBOutlet private weak var _lblScanInfoTxt: UILabel!
    @IBOutlet weak var _viewEPassportScan: UIView!
    
    @IBOutlet weak var _viewScanner: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._viewEPassportScan.isHidden = true
        _viewLiveIDScan.isHidden = true
        _viewLiveIDScan.frame = CGRect(x: 0, y: 0, width: self._viewScanner.frame.width, height: 500)
        self._viewScanner.addSubview(_viewLiveIDScan)
        
        startPassportScanning()
        _viewLiveIDScan.isHidden = false
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
                    self._viewBG.isHidden = false
                    self._viewLiveIDScan.isHidden = false
                    //3. Initialize PassportScannerHelper
                    if self.ppScannerHelper == nil {
                        self.ppScannerHelper = PassportScanHelper.init(scanningMode: self.selectedMode, bidScannerView: self._viewLiveIDScan, ppResponseDelegate: self, cutoutView: self._imgOverlay, expiryGracePeriod: self.expiryDays)
                    }
                    //4. Start Scanning
                    self.ppScannerHelper?.startPassportScanning()
                    
                    self._scanLine = self.addScanLine(self._imgOverlay.frame)
                    self._imgOverlay.layer.addSublayer(self._scanLine)
                }
            }
        }
        
    }
    
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func cancelClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to cancel the registration process?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.ppScannerHelper?.stopPassportScanning()
            self.goBack()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        self.present(alert, animated: true)
        return
    }
    
    private func setPassport(withPPDat pp: BIDPassport, token: String, isWithNFC: Bool) {
        self.view.makeToastActivity(.center)
        let docObject = DocumentMapUtil.getDocumentMap(documentData: pp, documentCategory: .identity_document)

        BlockIDSDK.sharedInstance.registerDocument(obj: docObject, docType: .passport, sigToken: token) { [self] (status, error) in
            DispatchQueue.main.async {
                self.view.hideToastActivity()
                if !status {
                    
                    if error?.code == CustomErrors.kLiveIDMandatory.code {
                        DocumentStore.sharedInstance.setData(docType: .passport, documentData: pp, token: token)
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
    
    private func startRFIDScanWorkflow(withPPDat pp: BIDPassport, token: String) {
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

            alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
                self._viewEPassportScan.isHidden = false
                self.ppScannerHelper?.startRFIDScanning()
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.setPassport(withPPDat: self.pp!, token: self._token, isWithNFC: false)
            }))
            self.present(alert, animated: true)
            return
            
        case CustomErrors.kPPRFIDTimeout.code:
            self.view.makeToast("Scan Again", duration: 3.0, position: .center, title: "Timeout", completion: {_ in
                self._viewEPassportScan.isHidden = false
                self.ppScannerHelper?.startRFIDScanning()
            })
            return
            
        default:
            self.view.makeToast(msg, duration: 3.0, position: .center, title: "Error", completion: {_ in
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
extension PassportViewController: PassportResponseDelegate {
    
    func passportScanCompleted(withBidPassport obj: BIDPassport?, error: ErrorResponse?, signatureToken signToken: String?, isWithRFID: Bool?) {
        assert(Thread.isMainThread, "call me on main thread")
        
        //Check for errors
        //  EXPIRED || INVALID || TIMEOUT || USER_CANCEL || LICENSE_KEY_DISABLED
        if error?.code == CustomErrors.kPPExpired.code ||
            error?.code == CustomErrors.kInvalidPP.code ||
            error?.code == CustomErrors.kPPRFIDTimeout.code ||
            error?.code == CustomErrors.kPPRFIDUserCancelled.code ||
            error?.code == CustomErrors.kLicenseyKeyNotEnabled.code {
            
            guard let err = error else {
                return
            }
            self.handleScanErrorResponse(error: err)
            
            return
        }
        scanCompleteUIUpdates()
        
        guard let pp = obj, let token = signToken else {
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

            alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
                self.ppScannerHelper?.stopPassportScanning()
                self.goBack()
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                
                if let isWithRFID = isWithRFID, !isWithRFID {
                    self.startRFIDScanWorkflow(withPPDat: pp, token: token)
                    return
                }
                self.setPassport(withPPDat: pp, token: token, isWithNFC: false)
            }))
            self.present(alert, animated: true)
            return
        }
        
        if let isWithRFID = isWithRFID, !isWithRFID {
            self.startRFIDScanWorkflow(withPPDat: pp, token: token)
            return
        }
        
        setPassport(withPPDat: pp, token: token, isWithNFC: isWithRFID ?? false)
        
    }
    
    func readyForDetection() {
        DispatchQueue.main.async {
            //Check if there are any existing animations
            if !(self._scanLine.animationKeys()?.count ?? 0 > 0) {
                self.animateScanLine(_scanLine: self._scanLine, height:  self._imgOverlay.frame.height)
               
        }
      }
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
