//
//  DriverLicenseViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import AVFoundation
import BlockIDSDK
import Toast_Swift
  
class DriverLicenseViewController: UIViewController {

    private var dlScannerHelper: DriverLicenseScanHelper?
    private let selectedMode: ScanningMode = .SCAN_LIVE
    private let firstScanningDocSide: DLScanningSide = .DL_BACK
    private let expiryDays = 90
    private var _scanLine: CAShapeLayer!
    
    @IBOutlet private weak var _viewBG: UIView!
    @IBOutlet private weak var _viewLiveIDScan: BIDScannerView!
    @IBOutlet private weak var _imgOverlay: UIImageView!
    @IBOutlet private weak var _lblScanInfoTxt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDLScanning()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.numberOfFacesNotification(_:)), name: NSNotification.Name(rawValue: "BlockIDFaceDetectionNotification"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "BlockIDFaceDetectionNotification"), object: nil)
    }

    @objc func numberOfFacesNotification(_ notification: Notification) {
        guard let faceCount = notification.userInfo?["numberOfFaces"] as? Int else { return }
        print ("Number of faces found: \(faceCount)")
        DispatchQueue.main.async {
            if faceCount > 0 {
                self._lblScanInfoTxt.text = "Faces found : \(faceCount)"
            } else {
                self._lblScanInfoTxt.text = "Scan Front"
            }
        }
    }

    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to cancel the registration process?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.dlScannerHelper?.stopDLScanning()
            self.goBack()
        }))
        self.present(alert, animated: true)
        return
        
    }
    
    private func startDLScanning() {
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
                    if self.dlScannerHelper == nil {
                        self.dlScannerHelper = DriverLicenseScanHelper.init(scanningMode: self.selectedMode, bidScannerView: self._viewLiveIDScan, dlScanResponseDelegate: self, cutoutView: self._imgOverlay.frame, expiryGracePeriod: self.expiryDays)
                    }
                    //4. Start Scanning
                    self._lblScanInfoTxt.text = DLScanningSide.DL_BACK == self.firstScanningDocSide ? "Scan Back" : "Scan Front"
                    self.dlScannerHelper?.startDLScanning(scanningSide: self.firstScanningDocSide)

                    self._scanLine = self.addScanLine(self._imgOverlay.frame)
                    self._imgOverlay.layer.addSublayer(self._scanLine)
                }
            }
        }
        
    }
    
    private func wantToVerifyAlert(withDLData dl: [String : Any]?, token: String) {
        let alert = UIAlertController(title: "Verification", message: "Do you want to verify your Driver License?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.verifyDL(withDLData: dl, token: token)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
            self.setDriverLicense(withDLData: dl, token: token)
        }))
        
        self.present(alert, animated: true)
    }
    
    private func verifyDL(withDLData dl: [String : Any]?, token: String) {
        self.view.makeToastActivity(.center)

        BlockIDSDK.sharedInstance.verifyDocument(dvcID: AppConsant.dvcID, dic: dl ?? [:]) { [self] (status, dataDic, error) in
            DispatchQueue.main.async {
                self.view.hideToastActivity()
                if !status {
                    //Verification failed
                    self.view.makeToast(error?.message ?? "Verification Failed", duration: 3.0, position: .center, title: "Error", completion: {_ in
                        self.goBack()
                    })
                    return
                }
                //Verification success
                self.setDriverLicense(withDLData: dl, token: token)
            }
        }
    }
  
    private func setDriverLicense(withDLData dl: [String : Any]?, token: String) {
        self.view.makeToastActivity(.center)
        var dic = dl
        dic?["category"] = RegisterDocCategory.Identity_Document.rawValue
        dic?["type"] = RegisterDocType.DL.rawValue
        dic?["id"] = dl?["id"]
        BlockIDSDK.sharedInstance.registerDocument(obj: dic ?? [:], sigToken: token) { [self] (status, error) in
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
                    
                    self.view.makeToast(error?.message, duration: 3.0, position: .center, title: "Error", completion: {_ in
                        self.goBack()
                    })
                    return
                }
                // SUCCESS
                self.view.makeToast("Driver License enrolled successfully", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
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

extension DriverLicenseViewController: DriverLicenseResponseDelegate {
    
    func dlScanCompleted(dlScanSide: DLScanningSide, dictDriveLicense: [String : Any]?, signatureToken signToken: String?, error: ErrorResponse?) {
        if (error as? ErrorResponse)?.code == CustomErrors.kUnauthorizedAccess.code {
            self.showAppLogin()
        }
        //Check If Expired, licenene key not enabled
        if error?.code == CustomErrors.kDocumentExpired.code || error?.code == CustomErrors.kLicenseyKeyNotEnabled.code {
            self.view.makeToast(error?.message, duration: 3.0, position: .center)
            return
        }
        
        scanCompleteUIUpdates()
        
        guard let dl = dictDriveLicense, let token = signToken else {
            self.view.makeToast(error?.message, duration: 3.0, position: .center)
            return
            
        }
        
        //Check if Not to Expiring Soon
        if error?.code != CustomErrors.kDocumentAboutToExpire.code {
            self.wantToVerifyAlert(withDLData: dl, token: token)
            return
        }
        
        //About to Expire, Show Alert
        let alert = UIAlertController(title: "Error", message: error!.message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.wantToVerifyAlert(withDLData: dl, token: token)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func scanFrontSide() {
        DispatchQueue.main.async {
            self._lblScanInfoTxt.text = "Scan Front"
            self.dlScannerHelper?.startDLScanning(scanningSide: .DL_FRONT)
        }
    }
    
    func scanBackSide() {
        DispatchQueue.main.async {
            self._lblScanInfoTxt.text = "Scan Back"
            self.dlScannerHelper?.startDLScanning(scanningSide: .DL_BACK)
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
