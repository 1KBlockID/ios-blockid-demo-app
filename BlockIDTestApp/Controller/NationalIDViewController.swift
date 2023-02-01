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
    
    @IBOutlet private weak var _viewBG: UIView!
    @IBOutlet private weak var _viewLiveIDScan: BIDScannerView!
    @IBOutlet private weak var _imgOverlay: UIImageView!
    @IBOutlet private weak var _lblScanInfoTxt: UILabel!
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startNationalIDScanning()
    }
    
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to cancel the registration process?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.nidScannerHelper?.stopNationalIDScanning()
            self.goBack()
        }))
        self.present(alert, animated: true)
        return
        
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
                    self._viewBG.isHidden = false
                    self._viewLiveIDScan.isHidden = false
                    //3. Initialize dlScannerHelper
                    if self.nidScannerHelper == nil {
                        self.nidScannerHelper = NationalIDScanHelper.init(bidScannerView: self._viewLiveIDScan, nidScanResponseDelegate: self, cutoutView:  self._imgOverlay.frame, expiryGracePeriod: self.expiryDays)
                    }
                    //4. Start Scanning
                    self._lblScanInfoTxt.text = NIDScanningSide.NATIONAL_ID_BACK == self.firstScanningDocSide ? "Scan Back" : "Scan Front"
                    self.nidScannerHelper?.startNationalIDScanning(scanningSide: self.firstScanningDocSide)
                    self._scanLine = self.addScanLine(self._imgOverlay.frame)
                    self._imgOverlay.layer.addSublayer(self._scanLine)
                }
            }
        }
        
    }

    private func setNationaID(withNIDData nid: [String : Any], token: String) {
        //self._viewBG.isHidden = true
        self.view.makeToastActivity(.center)
        var dic = nid
        dic["category"] = RegisterDocCategory.Identity_Document.rawValue
        dic["type"] = RegisterDocType.NATIONAL_ID.rawValue
        dic["id"] = nid["id"] as! String
        BlockIDSDK.sharedInstance.registerDocument(obj: dic, sigToken: token) { [self] (status, error) in
            DispatchQueue.main.async {
                self.view.hideToastActivity()
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
