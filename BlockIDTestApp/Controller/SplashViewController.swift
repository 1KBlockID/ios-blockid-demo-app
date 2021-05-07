//
//  SplashViewController.swift
//  BlockIDTestApp
//
//  Created by vaidehi hindlekar on 03/05/21.
//

import UIKit
import BlockIDSDK
import Toast_Swift

class SplashViewController: UIViewController {

    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var loginView: UIView!
    
    private var isDefaultTenantRegistration = true
    private var bidTenant: BIDTenant!
    
    @IBOutlet weak var btnAppPin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAppVersion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
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
                self?.enrollDeviceAuth()
               
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
    
    private func enrollDeviceAuth() {
        BIDAuthProvider.shared.enrollDeviceAuth { (success, error, message) in
            if success {
                BlockIDSDK.sharedInstance.commitApplicationWallet()
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
            self.btnRegister.isHidden = true
            self.loginView.isHidden = false
            if BlockIDSDK.sharedInstance.isPinRegistered() {
                self.btnAppPin.isUserInteractionEnabled = true
                self.btnAppPin.backgroundColor = UIColor.black
            }
        }
        else {
            self.btnRegister.isHidden = false
            self.loginView.isHidden = true
        }
    }
   
}

