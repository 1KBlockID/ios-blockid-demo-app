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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func moveBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func processRestoreAccount(_ mnemonic: String) {
        if BlockIDSDK.sharedInstance.generateWalletForRestore(mnemonics: mnemonic) {
            BlockIDSDK.sharedInstance.setRestoreMode()
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
        } else {
            self.view.makeToast("Security phrase error. Try again.", duration: 3.0, position: .bottom)
        }
    }
    
    @IBAction func btnRestoreAccountClicked(_ sender: UIButton) {
        var strMnemonics = ""
        for index in 1..<13 {
            let txtField = self.view.viewWithTag(index) as! UITextField
            if txtField.text?.count ?? 0 == 0 {
                self.view.makeToast("Please recheck the mnemonics you entered.", duration: 3.0, position: .bottom)
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
        self.view.makeToastActivity(.center)
        
        BlockIDSDK.sharedInstance.registerTenant(tenant: bidTenant) { [weak self] (status, error, tenant) in
            self?.view.hideToastActivity()
            if status {
                //On Success, process restore
                BlockIDSDK.sharedInstance.restoreUserDataFromWallet { isSuccess, error in
                    if isSuccess {
                        BlockIDSDK.sharedInstance.commitTempData()
                        //navigate auth screen
                        let alert = UIAlertController(title: "Success", message: "Your account successfully restored!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            let navSplashControllerObj = self?.storyboard?.instantiateViewController(withIdentifier: "navSplash")
                            UIApplication.shared.windows.first?.rootViewController = navSplashControllerObj
                            UIApplication.shared.windows.first?.makeKeyAndVisible()
                        }))
                        self?.present(alert, animated: true, completion: nil)
                        
                        
                    } else {
                        BlockIDSDK.sharedInstance.resetRestorationData()
                        self?.showAlertView(title: "Error", message: "Account restoration failed.")

                    }
                }
               
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
}
