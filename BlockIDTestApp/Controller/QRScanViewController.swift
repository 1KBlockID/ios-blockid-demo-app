//
//  QRScanViewController.swift
//  BlockIDTestApp
//
//  Created by vaidehi hindlekar on 07/05/21.
//

import Foundation
import AVFoundation
import BlockIDSDK
import Toast_Swift

public enum QROptions {
    case withScopeData
    case withPresetData
}

class QRScanViewController: UIViewController {
    private var qrOption = QROptions.withScopeData
    @IBOutlet weak var btnQr1: UIButton!
    
    @IBOutlet weak var btnQr2: UIButton!
    @IBOutlet weak var _viewQRScan: BIDScannerView!
    
    @IBOutlet weak var _viewBtn: UIView!
    private var qrScannerHelper: QRScannerHelper?
    // MARK: - selectedMode Scanning Mode
    private let selectedMode: ScanningMode = .SCAN_LIVE
    
    
    @IBAction func qrOptionButtonClicked(_ sender: UIButton) {
        qrOption = (sender.tag == 0) ? QROptions.withScopeData : QROptions.withPresetData
        
        self.scanQRCode()
    }
    
    private func scanQRCode() {
        _viewQRScan.isHidden = false
        _viewBtn.isHidden = true
        qrScannerHelper = QRScannerHelper.init(scanningMode: selectedMode, bidScannerView: _viewQRScan, kQRScanResponseDelegate: self)
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
        _viewQRScan.isHidden = true
        self.processQRData(qrCodeData ?? "")
    }
    
    private func processQRData(_ data: String) {
        //decode the base64 payload data
        
        guard let decodedData = Data(base64Encoded: data) else {
            self.inValidQRCode()
            return
        }
        let decodedString = String(data: decodedData, encoding: .utf8)!
        let qrModel = CommonFunctions.jsonStringToObject(json: decodedString) as AuthQRModel?
        
        // 1. Scopes converted to lowercase
        qrModel?.scopes = qrModel?.scopes?.lowercased()
        
        // 2. If scopes has "windows", replace it by "scep_creds"
        qrModel?.scopes = qrModel?.scopes?.replacingOccurrences(of: "windows", with: "scep_creds")
        presentConsentViewWithData(qrdata: qrModel!)
    }
    
    private func inValidQRCode() {
        self._viewBtn.isHidden = false
        self._viewQRScan.isHidden = true
        self.showAlertView(title: "Invalid Code", message: "Unsupported QR code detected.")
    }
    
    private func presentConsentViewWithData(qrdata: AuthQRModel) {
        self._viewBtn.isHidden = false
        self._viewQRScan.isHidden = true
        self.showAuthenticationViewController(qrModel: qrdata, qrOption: qrOption,  delegate: self)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to cancel the registration process?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.goBack()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        self.present(alert, animated: true)
        return
    }
}
public class AuthQRModel: NSObject, Codable {
    public var authtype: String? = ""
    public var scopes: String? = ""
    public var creds: String? = ""
    public var publicKey: String? = ""
    public var session: String? = ""
    public var api: String? = ""
    public var tag: String? = ""
    public var community: String? = ""
    public var authPage: String? = ""
    public var name: String? = ""
    
    func getBidOrigin() -> BIDOrigin? {
        let bidOrigin = BIDOrigin()
        bidOrigin.api = self.api
        bidOrigin.tag = self.tag
        bidOrigin.name = self.name
        bidOrigin.community = self.community
        bidOrigin.publicKey = self.publicKey
        bidOrigin.session = self.session
        bidOrigin.authPage = self.authPage
        
        if (bidOrigin.authPage == nil) { //default to native auth without a specific method.
            bidOrigin.authPage = AccountAuthConstants.kNativeAuthScehema
        }
        
        return bidOrigin
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
}
extension QRScanViewController: AuthenticateViewControllerDelegate {
    func onAuthenticate(status: Bool) {
        self.goBack()
    }
    
    func unauthorisedUser() {
        self.showAppLogin()
    }
    
    
}
