//
//  QRScanViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import AVFoundation
import BlockID
import Toast_Swift

public enum QROptions {
    case withScopeData
    case withPresetData
}

class QRScanViewController: UIViewController {
    
    @IBOutlet weak var btnQr1: UIButton!
    @IBOutlet weak var btnQr2: UIButton!
    @IBOutlet weak var _viewQRScan: BIDScannerView!
    @IBOutlet weak var _qrView: UIView!
    @IBOutlet weak var _viewBtn: UIView!
    
    private var qrOption = QROptions.withScopeData
    private var qrScannerHelper: QRScannerHelper?
    
    @IBAction func qrOptionButtonClicked(_ sender: UIButton) {
        qrOption = (sender.tag == 0) ? QROptions.withScopeData : QROptions.withPresetData
        
        self.scanQRCode()
    }
    
    private func scanQRCode() {
        _qrView.isHidden = false
        _viewBtn.isHidden = true
        qrScannerHelper = QRScannerHelper.init(bidScannerView: _viewQRScan,
                                               kQRScanResponseDelegate: self)
        qrScannerHelper?.startQRScanning()
    }
    
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
extension QRScanViewController: QRScanResponseDelegate {
    func onQRScanResult(qrCodeData: String?) {
        if qrCodeData == nil {
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if !response {
                    DispatchQueue.main.async {
                        self.alertForCameraAccess()
                    }
                }
            }
            return
        }
        qrScannerHelper?.stopQRScanning()
        _qrView.isHidden = true
        
        self.processQRData(qrCodeData ?? "")
        
    }
    
    private func processQRData(_ data: String) {
        
        // uwl 2.0
        if data.hasPrefix("https://") && data.contains("/sessions") {
            handleUWL2(data: data)
            return
        }
        
        // uwl 1.0
        //decode the base64 payload data
        guard let decodedData = Data(base64Encoded: data) else {
            self.inValidQRCode()
            return
        }
        
        let decodedString = String(data: decodedData, encoding: .utf8)!
        let qrModel = CommonFunctions.jsonStringToObject(json: decodedString) as AuthenticationPayloadV1?
        
        // 1. Scopes converted to lowercase
        qrModel?.scopes = qrModel?.scopes?.lowercased()
        
        // 2. If scopes has "windows", replace it by "scep_creds"
        qrModel?.scopes = qrModel?.scopes?.replacingOccurrences(of: "windows", with: "scep_creds")
        presentConsentViewWithData(qrdata: qrModel!)
    }
    
    private func processScope(qrModel: AuthenticationPayloadV1?) {
        // 1. Scopes converted to lowercase
        qrModel?.scopes = qrModel?.scopes?.lowercased()
        // 2. If scopes has "windows", replace it by "scep_creds"
        qrModel?.scopes = qrModel?.scopes?.replacingOccurrences(of: "windows", with: "scep_creds")
        if let qrModel = qrModel {
            presentConsentViewWithData(qrdata: qrModel)
        }
    }
    
    private func handleUWL2(data: String) {
        
        let arrSplitStrings = data.components(separatedBy: "/session/")
        let url = arrSplitStrings.first ?? ""
        
        
        BlockIDSDK.sharedInstance.isTrustedSessionSources(sessionUrl: url) { isTrusted in
            if(!isTrusted){
                // Show toast
                self.view.makeToast("Suspicious QR Code", duration: 3.0, position: .center, title: "Error", completion: {_ in
                    self.goBack()
                    return
                })
                return
            }
            
            GetSessionData.sharedInstance.getSessionData(url: data) { [self] response, message, isSuccess in
                if isSuccess {
                    let authQRUWL2 = CommonFunctions.jsonStringToObject(json: response ?? "") as AuthenticationPayloadV2?
                    let authQRUWL1 = authQRUWL2?.getAuthRequestModel(sessionUrl: data)
                    processScope(qrModel: authQRUWL1)
                } else {
                    // Show toast
                    self.view.makeToast(message, duration: 3.0, position: .center, title: "Error", completion: {_ in
                        self.goBack()
                        return
                    })
                }
            }
        }
    }
    
    private func inValidQRCode() {
        self._viewBtn.isHidden = false
        self._qrView.isHidden = true
        self.showAlertView(title: "Invalid Code", message: "Unsupported QR code detected.")
    }
    
    private func presentConsentViewWithData(qrdata: AuthenticationPayloadV1) {
        self._viewBtn.isHidden = false
        self._qrView.isHidden = true
        self.navigationController?.popViewController(animated: true)
        self.showAuthenticationViewController(qrModel: qrdata, qrOption: qrOption,  delegate: self)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to cancel the QR Login?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.goBack()
        }))
        self.present(alert, animated: true)
        return
        
    }
}

public struct AuthRequestModel {
    var lat: Double = 0.0
    var lon: Double = 0.0
    var session: String = ""
    var creds: String = ""
    var scopes: String = ""
    var origin: BIDOrigin!
    var isConsentGiven: Bool = false
    var userId: String?
    var sessionUrl: String = ""
}
extension QRScanViewController: AuthenticateViewControllerDelegate {
    func onAuthenticate(status: Bool) {
        self.goBack()
    }
    
    func unauthorisedUser() {
        self.showAppLogin()
    }
    
    
}
