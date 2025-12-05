//
//  ViewControllerExtension.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import UIKit
import BlockID

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
    
    public func  resetAppNSDK(_ reason: String) {
        //If launched using Magic-Link
        //Need to resave magic-link once app is reset
        UserDefaults.removeAllValues()
        BlockIDSDK.sharedInstance.resetSDK(licenseKey: Tenant.licenseKey,
                                           rootTenant: Tenant.defaultTenant,
                                           reason: reason)
    }
    
    func showEnrollmentView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let enrollMentvC = storyBoard.instantiateViewController(withIdentifier: "EnrollMentViewController") as! EnrollMentViewController
        self.navigationController?.pushViewController(enrollMentvC, animated: true)
    }

    func verifyDocumentWithStoreId(_ docTitle: Enrollments) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let docVerifyVC = storyBoard.instantiateViewController(withIdentifier: "DocumentScannerWithStoreIdVC") as? DocumentScannerWithStoreIdVC {
            docVerifyVC.documentTitle = docTitle
            self.navigationController?.pushViewController(docVerifyVC, animated: true)
        }
    }
    
    func showDocumentScannerFor(_ docType: DocumentScannerType, _ storeId: String?, _ delegate: DocumentScanDelegate) {
        debugPrint("Prasanna: storeId", #function, storeId)
        let document = DocumentScannerViewController(docType: docType,
                                                     storeId: storeId,
                                                     delegate: delegate)
        self.navigationController?.pushViewController(document, animated: false)
    }
    
    func showDLView(storeId: String? = nil) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let dlVC = storyBoard.instantiateViewController(withIdentifier: "DriverLicenseViewController") as? DriverLicenseViewController {
            dlVC.storeId = storeId
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
        if let ssnVC = storyBoard.instantiateViewController(withIdentifier: "SSNViewController") as? SSNViewController {
            self.navigationController?.pushViewController(ssnVC, animated: true)
        }
    }
    
    func showPassportView(storeId: String? = nil) {
       let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let ppVC = storyBoard.instantiateViewController(withIdentifier: "PassportViewController") as? PassportViewController {
            ppVC.storeId = storeId
            self.navigationController?.pushViewController(ppVC, animated: true)
        }
    }
    
    func showNationalIDView(storeId: String? = nil) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let nidVC = storyBoard.instantiateViewController(withIdentifier: "NationalIDViewController") as? NationalIDViewController {
            nidVC.storeId = storeId
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
    
    
    func showLiveIDView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let liveIDVC = storyBoard.instantiateViewController(withIdentifier: "LiveIDViewController") as? LiveIDViewController {
            self.navigationController?.pushViewController(liveIDVC, animated: true)
        }
    }
    
    func showLiveIDLivenessAndCompareView() {
        if BlockIDSDK.sharedInstance.isLiveIDRegisterd() {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            if let liveIDVC = storyBoard.instantiateViewController(withIdentifier: "LiveIDViewController") as? LiveIDViewController {
                liveIDVC.isForFaceCompareAndVerification = true
                    self.navigationController?.pushViewController(liveIDVC, animated: true)
               
            }
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
    
    /// About VC
    public func showAboutScreen() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let aboutVC = storyBoard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        self.navigationController?.pushViewController(aboutVC, animated: true)
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
        self.openSettings(title: "Camera Inaccessible",
                          message: "Please note that you will not be able to scan any of your documents with App and verify your identity unless you permit access to the camera")
    }
    
    func showPasskeysViewController() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let passkeyVC = storyBoard.instantiateViewController(withIdentifier: "PasskeyViewController") as? PasskeyViewController {
            self.navigationController?.pushViewController(passkeyVC, animated: true)
        }
    }
    
    // MARK: - Topmost View Controller
    func topMostViewController() -> UIViewController? {
        // if root view is Navigation
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController()
        }
        // if root view is Tab
        if let tabController = self as? UITabBarController {
            if let selectedTab = tabController.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tabController.topMostViewController()
        }
        // otherwise
        if self.presentedViewController == nil {
            return self
        }
        // Navigation
        if let navigationCon = self.presentedViewController as? UINavigationController {
            if let visibleController = navigationCon.visibleViewController {
                return visibleController.topMostViewController()
            }
        }
        // Tab
        if let tabCon = self.presentedViewController as? UITabBarController {
            if let selectedTab = tabCon.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tabCon.topMostViewController()
        }
        // otherwise
        return self.presentedViewController?.topMostViewController()
    }
    
    // MARK: - Rotate View Infinite (For Loader)-
    func rotateView(_ targetView: UIView, _ duration: Double = 2) { // Duration will helps to control rotation speed
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            targetView.transform = targetView.transform.rotated(by: .pi)
        }) { finished in
            self.rotateView(targetView, duration)
        }
    }
}

