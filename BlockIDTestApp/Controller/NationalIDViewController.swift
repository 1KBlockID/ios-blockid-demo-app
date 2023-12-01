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

    private var nidScannerHelper: NationalIDScanHelper?
    private let firstScanningDocSide: NIDScanningSide = .NATIONAL_ID_BACK
    private let expiryDays = 90
    private var _scanLine: CAShapeLayer!
    private var registrationCalled = false
    private let kIDCardFailedMessage = "National ID failed to scan."
    @IBOutlet private weak var _viewBG: UIView!
    @IBOutlet private weak var _viewLiveIDScan: BIDScannerView!
    @IBOutlet private weak var _imgOverlay: UIImageView!
    @IBOutlet private weak var _lblScanInfoTxt: UILabel!
    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var imgLoader: UIImageView!
 
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start loader spin
        self.rotateView(imgLoader)
        // Start ID CARD loading
        startNationalIDScanning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint("***** viewWillAppear", self.description)
    }
    
    // MARK:
    private func goBack(isDelayReuired: Bool = false) {
        if isDelayReuired {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
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

    private func setNationaID(withNIDData nid: [String : Any], token: String) {
        if registrationCalled {
            return
        }
        registrationCalled = true
        debugPrint("***** setNationaID")
        var dic = nid
        dic["category"] = RegisterDocCategory.Identity_Document.rawValue
        dic["type"] = RegisterDocType.NATIONAL_ID.rawValue
        dic["id"] = nid["id"] as! String
        BlockIDSDK.sharedInstance.registerDocument(obj: dic, sigToken: token) { [self] (status, error) in
            DispatchQueue.main.async {
                if !status {
                    // FAILED
                    if error?.code == CustomErrors.kLiveIDMandatory.code {
                        DocumentStore.sharedInstance.setData(documentData: dic, token: token)
                        self.goBack()
                        self.showLiveIDView()
                        return
                    }
                    
                    self.view.makeToast(error?.message, duration: 3.0, position: .center, title: "Error!", completion: {_ in
                        self.goBack()
                    })
                    return
                }
                // SUCCESS
                self.view.makeToast("National ID enrolled successfully.", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
                    self.goBack()
                })
            }
        }
    }
    
    private func scanCompleteUIUpdates() {
        self._lblScanInfoTxt.text = "Scan Complete"
        _scanLine.removeAllAnimations()
    }
}

// MARK: - DocumentSessionScanDelegate -
extension NationalIDViewController: DocumentScanDelegate {
    fileprivate func showErrorAndMoveBack(_ message: String = "") {
        self.view.makeToast(message,
                            duration: 3.0,
                            position: .center)
        self.goBack(isDelayReuired: true)
    }
    
    func onDocumentScanResponse(status: Bool, document: String?, error: ErrorResponse?) {
        
        if error?.code == CustomErrors.kUnauthorizedAccess.code {
            self.showAppLogin()
        }
        
        if error?.code == CustomErrors.License.MODULE_NOT_ENABLED.code {
            let localizedMessage = "MODULE_NOT_ENABLED".localizedMessage(CustomErrors.License.MODULE_NOT_ENABLED.code)
            self.showErrorAndMoveBack(localizedMessage)
            return
        }
        
        if error?.code == CustomErrors.DocumentScanner.CANCELED.code { // Cancelled
            self.goBack()
        }
       
        if error?.code == CustomErrors.DocumentScanner.TIMEOUT.code {
            self.showErrorAndMoveBack("Scanning time exceeded. To continue, please restart the scanning process.")
            return
        }
        
        guard let idCardObject = document else {
            self.showErrorAndMoveBack(kIDCardFailedMessage)
           return
        }
        guard let dictDocObject = CommonFunctions.jsonStringToDic(from: idCardObject) else {
            self.showErrorAndMoveBack(kIDCardFailedMessage)
            return
        }
        guard let  responseStatus = dictDocObject["responseStatus"] as? String else {
            self.showErrorAndMoveBack(kIDCardFailedMessage)
           return
        }
        if responseStatus == "FAILED" {
            self.showErrorAndMoveBack(kIDCardFailedMessage)
          return
        }
        guard let token = dictDocObject["token"] as? String, !token.isEmpty else {
            self.showErrorAndMoveBack(kIDCardFailedMessage)
            return
        }
        guard var dictIdcardObject = dictDocObject["idcard_object"] as? [String: Any] else {
            self.showErrorAndMoveBack(kIDCardFailedMessage)
           return
        }
        guard let proof_jwt = dictIdcardObject["proof_jwt"] as? String, !proof_jwt.isEmpty else {
            self.showErrorAndMoveBack(kIDCardFailedMessage)
            return
        }
        
        dictIdcardObject["proof"] = proof_jwt
        dictIdcardObject["certificate_token"] = token
        self.setNationaID(withNIDData: dictIdcardObject, token: "")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}


/*
extension NationalIDViewController: NationalIDResponseDelegate {
    func nidScanCompleted(nidScanSide: NIDScanningSide, dictNationalID: [String : Any]?, signatureToken signToken: String?, error: ErrorResponse?) {
        if (error as? ErrorResponse)?.code == CustomErrors.kUnauthorizedAccess.code {
           self.showAppLogin()
        }
        //Check If Expired, licenene key not enabled
        if error?.code == CustomErrors.kDocumentExpired.code {
            self.view.makeToast(error?.message,
                                duration: 3.0,
                                position: .center)
            return
        }
        
        if error?.code == CustomErrors.License.MODULE_NOT_ENABLED.code {
            let localizedMessage = "MODULE_NOT_ENABLED".localizedMessage(CustomErrors.License.MODULE_NOT_ENABLED.code)
            self.view.makeToast(localizedMessage,
                                duration: 3.0,
                                position: .center)
            return
        }
        
        scanCompleteUIUpdates()
        guard let nid = dictNationalID, let token = signToken else {
            self.view.makeToast(error?.message,
                                duration: 3.0,
                                position: .center)
            return

        }
        
        //Check if Not to Expiring Soon
        if error?.code != CustomErrors.kDocumentAboutToExpire.code {
            self.setNationaID(withNIDData: nid, token: token)
            return
        }

        //About to Expire, Show Alert
        let alert = UIAlertController(title: "Error", message: error!.message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.setNationaID(withNIDData: nid, token: token)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        self.present(alert, animated: true)
      }
    

      
    func scanFrontSide() {
        DispatchQueue.main.async {
            self._lblScanInfoTxt.text = "Scan Front"
            self.nidScannerHelper?.startNationalIDScanning(scanningSide: .NATIONAL_ID_FRONT)
        }
    }
    
    func scanBackSide() {
        DispatchQueue.main.async {
            self._lblScanInfoTxt.text = "Scan Back"
            self.nidScannerHelper?.startNationalIDScanning(scanningSide: .NATIONAL_ID_BACK)
        }
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
*/
