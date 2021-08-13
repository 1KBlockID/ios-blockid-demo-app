//
//  RestoreAccountViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering on 10/08/21.
//

import UIKit
import BlockIDSDK
class RestoreAccountViewController: UIViewController ,UITextFieldDelegate{
    private var isDefaultTenantRegistration = true
    private var bidTenant: BIDTenant!
    var pasteBoardText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        pasteBoardText = UIPasteboard.general.string ?? ""
       
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(appMovedToForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.contains(pasteBoardText) {
            let arrMnemonics = string.components(separatedBy: " ")
            for index in 1..<13 {
                let txtField = self.view.viewWithTag(index) as! UITextField
                if arrMnemonics[index-1].count != 0 {
                    txtField.text = arrMnemonics[index-1]
                }
            }
                return false
        }
        return true
    }
    
    @objc func appMovedToForeground() {
        self.pasteBoardText = UIPasteboard.general.string ?? ""
    }
   
    @IBAction func moveBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func processRestoreAccount(_ mnemonic: String) {
        if BlockIDSDK.sharedInstance.generateWalletForRestore(mnemonics: mnemonic) {
            BlockIDSDK.sharedInstance.setRestoreMode()
            self.view.makeToastActivity(.center)
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
                    self?.view.hideToastActivity()
                }
                
//                self?.view.hideToastActivity()
            }
        } else {
            self.view.hideToastActivity()
            self.view.makeToast("Security phrase error. Try again.", duration: 3.0, position: .bottom)
        }
    }
    
    @IBAction func btnRestoreAccountClicked(_ sender: UIButton) {
        var strMnemonics = ""
        for index in 1..<13 {
            let txtField = self.view.viewWithTag(index) as! UITextField
            if txtField.text?.count ?? 0 == 0 {
                self.view.makeToast("Please enter all 12 mnemonic phrase.", duration: 3.0, position: .bottom)
                return
            } else {
                if strMnemonics.count != 0 {
                    strMnemonics.append(" ")
                }
                strMnemonics.append(txtField.text ?? "")
            }
        }
        processRestoreAccount(strMnemonics)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    private func beginRegistration(bidTenant: BIDTenant) {
        assert(Thread.isMainThread, "call me on main thread")
//        self.view.makeToastActivity(.center)
        
        BlockIDSDK.sharedInstance.registerTenant(tenant: bidTenant) { [weak self] (status, error, tenant) in
            if status {
                //On Success, process restore
                BlockIDSDK.sharedInstance.restoreUserDataFromWallet { isSuccess, error in
                    if isSuccess {
                        BlockIDSDK.sharedInstance.commitTempData()
                        //navigate auth screen
                        let alert = UIAlertController(title: "Success", message: "Your account successfully restored!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                           
                            let viewController = self?.navigationController?.viewControllers.first as! SplashViewController
                            viewController.isRestoredModeEnabled = true
                            self?.navigationController?.popViewController(animated: true)
                            
                        }))
                        self?.present(alert, animated: true, completion: nil)
                       
                        print("isRestored >>>> ",BlockIDSDK.sharedInstance.isReady())

                    } else {
                        BlockIDSDK.sharedInstance.resetRestorationData()
                        self?.showAlertView(title: "Error", message: "Account restoration failed.")

                    }
                    self?.view.hideToastActivity()
                }
            } else {
                if error?.code == NSURLErrorNotConnectedToInternet {
                    self?.showAlertView(title: "", message: error!.message)
                }
                else {
                    self?.showAlertView(title: "", message: error!.message)
                }
                self?.view.hideToastActivity()
            }
        }
    }
}
