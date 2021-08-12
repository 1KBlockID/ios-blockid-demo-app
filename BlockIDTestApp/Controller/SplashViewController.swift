//
//  SplashViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import UIKit
import BlockIDSDK
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
        self.registerView.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        BlockIDSDK.sharedInstance.setLicenseKey(key: Tenant.licenseKey)
        setRegisterButtonTitle()
    }
    
    private func checkAppVersion()
    {
        let buildVer = UserDefaults.standard.string(forKey: AppConsant.buildVersion)
        if buildVer == nil {
            resetAppNSDK()
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
        
        BlockIDSDK.sharedInstance.registerTenant(tenant: bidTenant) { [weak self] (status, error, tenant) in
            self?.view.hideToastActivity()
            if status {
                //On Success
                self?.btnRegister.isHidden = true
                self?.registerView.isHidden = false
                self?.btnRestoreAccount.isHidden = true
            } else {
                if error?.code == NSURLErrorNotConnectedToInternet {
                    self?.showAlertView(title: "", message: error!.message)
                }
                else {
                    self?.showAlertView(title: "", message: error!.message)
                }
            }
        }
    }
    
    
    @IBAction func btnRegisterDeviceAuth(_ sender: UIButton) {
        self.enrollDeviceAuth()
    }
    private func enrollDeviceAuth() {
        BIDAuthProvider.shared.enrollDeviceAuth { (success, error, message) in
            if success {
                if !self.isRestoredModeEnabled {
                    BlockIDSDK.sharedInstance.commitApplicationWallet()
                }
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

