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
    
    @IBAction func btnRestoreAccountClicked(_ sender: UIButton) {
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
