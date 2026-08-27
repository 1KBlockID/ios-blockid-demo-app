//
//  SplashViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import UIKit
import BlockID
import Toast_Swift

class SplashViewController: UIViewController {

    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var loginView: UIView!
    
    private var isDefaultTenantRegistration = true
    var isRestoredModeEnabled = false
    @IBOutlet weak var btnRegisterDeviceAuth: UIButton!
    private var bidTenant: BIDTenant!
    @IBOutlet weak var btnRestoreAccount: UIButton!
    
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var btnAppPin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAppVersion()
        setupLogoTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
        self.registerView.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // To set any proxy uncomment below line
        /*BlockIDSDK.sharedInstance.setProxy(host: "209.127.191.180",
                                           port: 9279,
                                           userName: "skfssubn",
                                           password: "esvgvx488tt3",
                                           isHTPPOnly: true)*/
        BlockIDSDK.sharedInstance.setLicenseKey(key: Tenant.licenseKey)
        setRegisterButtonTitle()
    }
    
    // MARK: - Logo Tap 5 Times Feature
    
    private func setupLogoTapGesture() {
        // Find the brandLogo imageView by tag or traverse subviews
        // The brandLogo is the first UIImageView in the view hierarchy
        guard let brandLogo = findBrandLogoImageView() else { return }
        brandLogo.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onLogoTap5Times))
        tapGesture.numberOfTapsRequired = 5
        brandLogo.addGestureRecognizer(tapGesture)
    }
    
    private func findBrandLogoImageView() -> UIImageView? {
        // The brandLogo is the first UIImageView subview of the main view
        for subview in self.view.subviews {
            if let imageView = subview as? UIImageView {
                return imageView
            }
        }
        return nil
    }
    
    @objc private func onLogoTap5Times() {
        showQRScanner()
    }
    
    private func showQRScanner() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let scanVC = storyboard.instantiateViewController(withIdentifier: "ScanQRViewController") as? ScanQRViewController {
            scanVC.delegate = self
            scanVC.modalPresentationStyle = .fullScreen
            self.present(scanVC, animated: true)
        }
    }
    
    private func processScannedQRData(_ data: String) {
        // UWL 2.0 — Session URL (e.g. https://uat-root.1kosmos.net/sessions/session/<id>)
        if data.hasPrefix("https://") && data.contains("/sessions/session/") {
            processSessionURL(data)
            return
        }
        
        // Base64-encoded JSON tenant data
        guard let decodedData = Data(base64Encoded: data),
              let _ = String(data: decodedData, encoding: .utf8) else {
            self.view.makeToast("Invalid QR code format", duration: 3.0, position: .bottom)
            return
        }
        
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: decodedData, options: []) as? [String: Any],
               let tag = jsonObject["tag"] as? String,
               let community = jsonObject["community"] as? String,
               let api = jsonObject["api"] as? String,
               !tag.isEmpty, !community.isEmpty, !api.isEmpty {
                
                bidTenant = BIDTenant.makeTenant(tag: tag, community: community, dns: api)
                isDefaultTenantRegistration = false
                self.view.makeToast("Tenant configured: \(tag)", duration: 3.0, position: .bottom)
            } else {
                self.view.makeToast("Invalid QR code data", duration: 3.0, position: .bottom)
            }
        } catch {
            self.view.makeToast("Invalid QR code format", duration: 3.0, position: .bottom)
        }
    }
    
    private func processSessionURL(_ sessionURL: String) {
        self.view.makeToastActivity(.center)
        
        let arrSplitStrings = sessionURL.components(separatedBy: "/session/")
        let baseURL = arrSplitStrings.first ?? ""
        
        BlockIDSDK.sharedInstance.isTrustedSessionSources(sessionUrl: baseURL) { [weak self] isTrusted in
            guard let self = self else { return }
            
            if !isTrusted {
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.view.makeToast("Suspicious QR Code", duration: 3.0, position: .bottom)
                }
                return
            }
            
            GetSessionData.sharedInstance.getSessionData(url: sessionURL) { [weak self] response, message, isSuccess in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    
                    if isSuccess, let responseStr = response,
                       let responseData = responseStr.data(using: .utf8),
                       let jsonObject = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                       let origin = jsonObject["origin"] as? [String: Any],
                       let tag = origin["tag"] as? String,
                       let url = origin["url"] as? String,
                       let communityName = origin["communityName"] as? String,
                       !tag.isEmpty, !url.isEmpty, !communityName.isEmpty {
                        
                        self.bidTenant = BIDTenant.makeTenant(tag: tag, community: communityName, dns: url)
                        self.isDefaultTenantRegistration = false
                        self.view.makeToast("Tenant configured: \(tag)", duration: 3.0, position: .bottom)
                    } else {
                        self.view.makeToast("Failed to get tenant info: \(message)", duration: 3.0, position: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Existing Methods
    
    private func checkAppVersion()
    {
        let buildVer = UserDefaults.standard.string(forKey: AppConsant.buildVersion)
        if buildVer == nil {
            resetAppNSDK(ResetSDK.freshInstallAndBuildVersionNotFound.message())
        }
        setVersionAndBuildNumber()
    }
    
    private func setVersionAndBuildNumber() {
        let (appVer, buildVerHex) = CommonFunctions.getAppBundleVersion()
        UserDefaults.standard.set(appVer, forKey: AppConsant.appVersionKey)
        UserDefaults.standard.set(buildVerHex, forKey: AppConsant.buildVersion)
    }
    
    @IBAction func onRegisterClicked(_ sender: Any) {
        //Normal Registration flow
        //step-1 : Initiate TEMP WALLET
       
        BlockIDSDK.sharedInstance.initiateTempWallet() { [weak self] (status, error) in
            if status {
               
                //step-2 : If TEMP WALLET Generated, Begin TENANT REGISTRATION
                if (self!.isDefaultTenantRegistration) {
                    self?.bidTenant = Tenant.defaultTenant
                }
                self?.beginRegistration(bidTenant: self!.bidTenant)
            }
            else {
                //Show Toast for user to TRY AGAIN!!!
                self?.view.makeToast(CustomErrors.kSomethingWentWrong.msg, duration: 3.0, position: .bottom)
            }
        }
    }
    
    private func beginRegistration(bidTenant: BIDTenant) {
        assert(Thread.isMainThread, "call me on main thread")
        self.view.makeToastActivity(.center)
        let title: String = "Error"
        var msg: String = ""
        BlockIDSDK.sharedInstance.registerTenant(tenant: bidTenant) { [weak self] (status, error, tenant) in
            self?.view.hideToastActivity()
            if status {
                BlockIDSDK.sharedInstance.commitApplicationWallet()
                //On Success
                self?.btnRegister.isHidden = true
                self?.registerView.isHidden = false
                self?.btnRestoreAccount.isHidden = true
            } else {
                switch error?.code {
                case  CustomErrors.Network.OFFLINE.code:
                    msg = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
                case CustomErrors.License.UNAUTHORIZED.code:
                    msg = "UNAUTHORIZED".localizedMessage(CustomErrors.License.UNAUTHORIZED.code)
                case CustomErrors.License.EXPIRED.code:
                    msg = "EXPIRED".localizedMessage(CustomErrors.License.EXPIRED.code)
                case CustomErrors.License.MODULES_EMPTY.code:
                    msg = "MODULES_EMPTY".localizedMessage(CustomErrors.License.MODULES_EMPTY.code)
                case CustomErrors.License.MODULE_NOT_ENABLED.code:
                    msg = "MODULE_NOT_ENABLED".localizedMessage(CustomErrors.License.MODULE_NOT_ENABLED.code)
                case CustomErrors.License.BAD_REQUEST.code:
                    msg = "BAD_REQUEST".localizedMessage(CustomErrors.License.BAD_REQUEST.code)
                case CustomErrors.License.INVALID.code:
                    msg = "INVALID".localizedMessage(CustomErrors.License.INVALID.code)
                 default:
                    msg = error?.message ?? ""
                }
                self?.showAlertView(title: title, message: msg)
            }
        }
    }
    
    
    @IBAction func btnRegisterDeviceAuth(_ sender: UIButton) {
        self.enrollDeviceAuth()
    }
    
    private func enrollDeviceAuth() {
        #if targetEnvironment(simulator)
        BlockIDSDK.sharedInstance.setPin(pin: "12345678", proofedBy: "blockid") { (success, error) in
            if success {
                self.showEnrollmentView()
            }
        }
        #endif
        BIDAuthProvider.shared.enrollDeviceAuth { (success, error, message) in
            if success {
                self.showEnrollmentView()
            }
        }
    }
    
    
    @IBAction func loginWithDeviceAuth(_ sender: Any) {
        self.loginWithDeviceAuth()
    }
    
    @IBAction func loginWithPin(_ sender: Any) {
        self.showPinView(pinActivity: .isLogin)
    }
    private func setRegisterButtonTitle() {
        if (BlockIDSDK.sharedInstance.isReady()) {
            if isRestoredModeEnabled {
                //On Success
                self.btnRegister.isHidden = true
                self.registerView.isHidden = false
                self.btnRestoreAccount.isHidden = true
            } else {
                self.btnRegister.isHidden = true
                self.btnRestoreAccount.isHidden = true
                self.loginView.isHidden = false
                if BlockIDSDK.sharedInstance.isPinRegistered() {
                    self.btnAppPin.isUserInteractionEnabled = true
                    self.btnAppPin.backgroundColor = UIColor.black
                }
            }
        }
        else {
            self.btnRegister.isHidden = false
            self.btnRestoreAccount.isHidden = false
            self.loginView.isHidden = true
        }
    }
   
}

// MARK: - ScanQRViewDelegate
extension SplashViewController: ScanQRViewDelegate {
    func scannedData(data: String) {
        processScannedQRData(data)
    }
}
