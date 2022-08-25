//
//  ViewControllerExtension.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import UIKit
import BlockIDSDK

extension UIViewController {
    
    // Mark: - Fix me -
    public func getDriverLicenseData(docIndex: Int, category: RegisterDocCategory) -> (docId: String?, islivenessNeeded: Bool?) {
        let strDocuments = BIDDocumentProvider.shared.getUserDocument(id: nil,
                                                                      type: RegisterDocType.DL.rawValue,
                                                                  category: category.rawValue) ?? ""
        guard let arrDocuments = CommonFunctions.convertJSONStringToJSONObject(strDocuments) as? [[String : Any]] else {
            return (nil, nil)
        }
        
        let index = (docIndex-1)
        if arrDocuments.count > index{
            let dictDoc = arrDocuments[index]
            return (dictDoc["id"] as? String, dictDoc["isLivenessRequired"] as? Bool)
        }
        return (nil, nil)
    }
    
    public func getDocumentID(docIndex: Int , type: RegisterDocType ,category: RegisterDocCategory) -> String? {
        let strDocuments = BIDDocumentProvider.shared.getUserDocument(id: nil,
                                                                  type: type.rawValue,
                                                                  category: category.rawValue) ?? ""
        guard let arrDocuments = CommonFunctions.convertJSONStringToJSONObject(strDocuments) as? [[String : Any]] else {
            return nil
        }
       
        let index = (docIndex-1)
        if arrDocuments.count > index{
            let dictDoc = arrDocuments[index]
            return dictDoc["id"] as? String
        }
        
        return nil
    }
    
    public func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)

    }
    
    public func  resetAppNSDK() {
        //If launched using Magic-Link
        //Need to resave magic-link once app is reset
        UserDefaults.removeAllValues()
        BlockIDSDK.sharedInstance.resetSDK(licenseKey: Tenant.licenseKey)
    }
    
    func showEnrollmentView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let enrollMentvC = storyBoard.instantiateViewController(withIdentifier: "EnrollMentViewController") as! EnrollMentViewController
        self.navigationController?.pushViewController(enrollMentvC, animated: true)
    }
    
    func showDLView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let dlVC = storyBoard.instantiateViewController(withIdentifier: "DriverLicenseViewController") as? DriverLicenseViewController {
            self.navigationController?.pushViewController(dlVC, animated: true)
        }
    }
    
    func showDocumentLivenessVC() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let documentLivenessVC = storyBoard.instantiateViewController(withIdentifier: "DocumentLivenessViewController") as? DocumentLivenessViewController {
            self.navigationController?.pushViewController(documentLivenessVC, animated: false)
        }
    }
    
    func showSSNVerificationView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let dlVC = storyBoard.instantiateViewController(withIdentifier: "SSNViewController") as? SSNViewController {
            self.navigationController?.pushViewController(dlVC, animated: true)
        }
    }
    
    func showPassportView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let ppVC = storyBoard.instantiateViewController(withIdentifier: "PassportViewController") as? PassportViewController {
            self.navigationController?.pushViewController(ppVC, animated: true)
        }
    }
    
    func showNationalIDView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let nidVC = storyBoard.instantiateViewController(withIdentifier: "NationalIDViewController") as? NationalIDViewController {
            self.navigationController?.pushViewController(nidVC, animated: true)
        }
    }
    
    func showAddUserViewController() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let addUserVC = storyBoard.instantiateViewController(withIdentifier: "AddUserViewController") as? AddUserViewController {
            self.navigationController?.pushViewController(addUserVC, animated: true)
        }
    }
    
    func showAuthenticationViewController(qrModel: AuthenticationPayloadV1, qrOption: QROptions, delegate: AuthenticateViewControllerDelegate ) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let authVc = storyBoard.instantiateViewController(withIdentifier: "AuthenticateViewController") as? AuthenticateViewController {
            authVc.qrModel =  qrModel
            authVc.delegate = delegate
            authVc.qrOption = qrOption
            self.navigationController?.pushViewController(authVc, animated: false)
        }
    }
    
    func showRFIDViewController(delegate: EPassportChipScanViewControllerDelegate) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if  let eRFIDVC = storyBoard.instantiateViewController(withIdentifier: "EPassportChipScanViewController") as? EPassportChipScanViewController {
            eRFIDVC.delegate = delegate
            self.navigationController?.pushViewController(eRFIDVC, animated: true)
        }
    }
    
    func showNFCDisableViewController(delegate: NFCDisabledViewControllerDelegate) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let disableRFIDVC = storyBoard.instantiateViewController(withIdentifier: "NFCDisabledViewController") as! NFCDisabledViewController
        disableRFIDVC.delegate = delegate
        self.navigationController?.pushViewController(disableRFIDVC, animated: true)
    }
    
    
    func showLiveIDView(isLivenessNeeded: Bool = false) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let liveIDVC = storyBoard.instantiateViewController(withIdentifier: "LiveIDViewController") as? LiveIDViewController {
            liveIDVC.isLivenessNeeded = isLivenessNeeded
            self.navigationController?.pushViewController(liveIDVC, animated: true)
        }
    }
    
    func showPinView(pinActivity : PinActivity) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let pinVC = storyBoard.instantiateViewController(withIdentifier: "PinViewController") as! PinViewController
        pinVC.pinActivity = pinActivity
        self.navigationController?.pushViewController(pinVC, animated: true)
    }
    
    func showHomeView() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    public func showAppLogin() {
        self.showHomeView()
    }
    
    public func showQROptions() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let qrScanVC = storyBoard.instantiateViewController(withIdentifier: "QRScanViewController") as! QRScanViewController
        self.navigationController?.pushViewController(qrScanVC, animated: true)
    }
    
    /// Wallet Connect VC
    func showWalletConnectVC() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let walletConnectVC = storyBoard.instantiateViewController(withIdentifier: "WalletConnectViewController") as? WalletConnectViewController {
            self.navigationController?.pushViewController(walletConnectVC, animated: false)
        }
    }
    
    public func loginWithDeviceAuth() {
        BIDAuthProvider.shared.verifyDeviceAuth { (success, error, message) in
            if !success {
                if let messageUW = message {
                    self.showAlertView(title: "", message: messageUW)
                }
            }
            self.showEnrollmentView()
        }
    }
    public func openSettings(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let OKAction = UIAlertAction(title: "Open Settings", style: .default) {
            (action: UIAlertAction!) in
            // Code in this block will trigger when OK button tapped.
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                })
            }
        }
        alert.addAction(OKAction)

        self.present(alert, animated: true)
    }

        
    public func addScanLine(_ superViewFrame: CGRect) -> CAShapeLayer {
        
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        let start = CGPoint(x: 0, y: 0)
        let end = CGPoint(x: superViewFrame.width, y: 0)
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.opacity = 1.0
        line.strokeColor = UIColor.gray.cgColor
        line.lineWidth = 1.5

        return line
    }
    
    public func animateScanLine(_scanLine: CAShapeLayer, height: CGFloat) {
        CATransaction.begin()
        
        let initialValue = _scanLine.position.y
        let finalValue = initialValue + height
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = initialValue
        animation.toValue = finalValue
        animation.duration = 2
        animation.repeatCount = .infinity
        _scanLine.add(animation, forKey: "Reposition")
        CATransaction.commit()
    }
    
    public func alertForCameraAccess() {
        self.openSettings(title: "Camera Inaccessible", message: "Please note that you will not be able to scan any of your documents with App and verify your identity unless you permit access to the camera")
    }
}

