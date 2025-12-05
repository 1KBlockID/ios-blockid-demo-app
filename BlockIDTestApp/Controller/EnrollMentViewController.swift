//
//  EnrollMentViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import BlockID
import Toast_Swift
import UIKit

public enum Enrollments: String {
    case About  = "About"
    case AddUser = "Add User"
    case Passkeys  = "Passkeys"
    case DriverLicense = "Drivers License 1"
    case DriverLicense_Liveness = "Drivers License (with Liveness Check)"
    case Passport1  = "Passport 1"
    case Passport2  = "Passport 2"
    case NationalID  = "National ID 1"
    case SSN = "Verify SSN"
    case KYC = "My KYC"
    case Pin  = "App Pin"
    case DeviceAuth  = "Device Auth"
    case LiveID  = "LiveID"
    case LiveIDLivenessAndCompare  = "LiveID Liveness & Compare"
    case LoginWithQR  = "Login With QR"
    case RecoverMnemonics  = "Recover Mnemonics"
    case resetApp  = "Reset App"
}

class EnrollMentViewController: UIViewController {
    
    var enrollmentArray = [Enrollments.About,
                           Enrollments.AddUser,
                           Enrollments.DriverLicense,
                           /*Enrollments.DriverLicense_Liveness,*/
                           Enrollments.Passport1,
                           Enrollments.Passport2,
                           Enrollments.NationalID,
                           Enrollments.SSN,
                           Enrollments.KYC,
                           Enrollments.Pin,
                           Enrollments.DeviceAuth,
                           Enrollments.LiveID,
                           Enrollments.LiveIDLivenessAndCompare,
                           Enrollments.LoginWithQR,
                           Enrollments.Passkeys,
                           Enrollments.RecoverMnemonics,
                           Enrollments.resetApp]
    
    @IBOutlet weak var tableEnrollments: UITableView!
    @IBOutlet weak var lblSDKVersion: UILabel!
    var enrollTableViewReuseIdentifier = "EnrollmentTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        tableEnrollments.register(UINib(nibName: "EnrollmentTableViewCell", bundle: nil), forCellReuseIdentifier: "EnrollmentTableViewCell")
        tableEnrollments.reloadData()
    }
}

extension EnrollMentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enrollmentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: enrollTableViewReuseIdentifier, for: indexPath) as! EnrollmentTableViewCell
        cell.controllerObj = self
        cell.setupCell(enrollment: enrollmentArray[indexPath.row])
        return cell
    }
}

extension EnrollMentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let enrolmentObj = enrollmentArray[indexPath.row].rawValue
        switch enrolmentObj {
        case Enrollments.AddUser.rawValue:
            addUser()
        case Enrollments.DriverLicense.rawValue:
            enrollDL()
        case Enrollments.DriverLicense_Liveness.rawValue:
            documentLivenessVC()
        case Enrollments.Passport1.rawValue:
            enrollPassport(index: 1)
        case Enrollments.Passport2.rawValue:
            enrollPassport(index: 2)
        case Enrollments.NationalID.rawValue:
            enrollNationalID()
        case Enrollments.SSN.rawValue:
            enrollSSN()
        case Enrollments.KYC.rawValue:
            getKYC()
        case Enrollments.Pin.rawValue:
            enrollPin()
        case Enrollments.DeviceAuth.rawValue:
            enrollDeviceAuth()
        case Enrollments.LiveID.rawValue:
            showLiveID()
        case Enrollments.LiveIDLivenessAndCompare.rawValue:
            showLiveIDLivenessAndCompareView()
        case Enrollments.LoginWithQR.rawValue:
            scanQRCode()
        case Enrollments.Passkeys.rawValue:
            showPasskeysViewController()
        case Enrollments.RecoverMnemonics.rawValue:
            recoverMnemonic()
        case Enrollments.resetApp.rawValue:
            resetApp()
        case Enrollments.About.rawValue:
            showAboutScreen()
        default:
            return
        }
    }
}

extension EnrollMentViewController {
    
    private func enrollDL() {
        let document = getDriverLicenseData(docIndex: 1, category: .Identity_Document)
        if let docId = document.docId,
            !docId.isEmpty,
            let isLivenessReq = document.islivenessNeeded, !isLivenessReq {
            let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to unenroll Drivers License?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.unenrollDocument(registerDocType: .DL, id: docId)
            }))
        
            self.present(alert, animated: true)
            return
        }
        verifyDocumentWithStoreId(.DriverLicense)
    }
    
    /**
            Name:  getKYC()
            Parameter: completion: KYCCallback type returns (status, kycHash 512 string, error)
     **/
    private func getKYC() {
        BlockIDSDK.sharedInstance.getKYC(completion: { (status, kycHash, error) in
            let title = "My KYC"
            if status {
                if let kycHash = kycHash {
                    self.showAlertView(title: title, message: "{\"kyc_hash\": \"\(kycHash)\"}")
                }
            } else {
                if let error = error {
                    let msg = "(" + "\(error.code)" + ") " + error.message
                    self.showAlertView(title: title, message: msg)
                }
            }
        })
    }
    
    private func enrollSSN() {
        
        let isDLEnrolled = BIDDocumentProvider.shared.getDocument(id: nil,
                                                                  type: RegisterDocType.DL.rawValue, category: nil) != nil
        
        let isSSNEnrolled = BIDDocumentProvider.shared.getDocument(id: nil,
                                                                  type: RegisterDocType.SSN.rawValue, category: nil) != nil
        
        guard isDLEnrolled else {
            self.view.makeToast("Please enroll your drivers license first.",
                                duration: 3.0,
                                position: .center)
            return
        }
        
        if isSSNEnrolled {
            let docID = self.getDocumentID(docIndex: 1, type: .SSN, category: .Identity_Document) ?? ""
            let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to remove SSN?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.unenrollDocument(registerDocType: .SSN, id: docID)
            }))
            
            self.present(alert, animated: true)
            return
        }
        self.showSSNVerificationView()
    }
    
    private func documentLivenessVC() {
        let document = getDriverLicenseData(docIndex: 1, category: .Identity_Document)
        if let docId = document.docId,
            !docId.isEmpty,
            let isLivenessReq = document.islivenessNeeded, isLivenessReq {
            let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to unenroll Drivers License?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.unenrollDocument(registerDocType: .DL, id: docId)
            }))
        
            self.present(alert, animated: true)
            return
        }
        showDocumentLivenessVC()
    }
    
    private func addUser() {
        if let linkedUserAccounts = BlockIDSDK.sharedInstance.getLinkedUserAccounts().linkedUsers, linkedUserAccounts.count > 0 {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            if let addUserVC = storyBoard.instantiateViewController(withIdentifier: "UserOptionsViewController") as? UserOptionsViewController {
                addUserVC.currentUser = linkedUserAccounts[0]
                self.navigationController?.pushViewController(addUserVC, animated: true)
            }
            return
        }
        showAddUserViewController()
    }
    
    private func unlinkUser(linkedAccount: BIDLinkedAccount) {
        
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.unLinkAccount(bidLinkedAccount: linkedAccount,
                                                deviceToken: nil) { [weak self] (success, error) in
            guard let weakSelf = self else {return}
            weakSelf.view.hideToastActivity()
            if success {
                weakSelf.view.makeToast("Your account is removed.", duration: 3.0, position: .center)
                weakSelf.tableEnrollments.reloadData()
            } else {
                // failure
                if error?.code == NSURLErrorNotConnectedToInternet ||
                    error?.code == CustomErrors.Network.OFFLINE.code {
                    let localizedMessage = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
                    self?.showAlertView(title: "Error", message: localizedMessage)
                    weakSelf.view.makeToast(localizedMessage,
                                            duration: 3.0,
                                            position: .center,
                                            title: ErrorConfig.noInternet.title,
                                            completion: nil)
                } else {
                    weakSelf.view.makeToast(error?.message,
                                            duration: 3.0,
                                            position: .center,
                                            title: ErrorConfig.error.title,
                                            completion: nil)
                }

            }
            
        }
        
    }
    
    private func unenrollDocument(registerDocType: RegisterDocType, id: String) {
        let strDoc = BIDDocumentProvider.shared.getUserDocument(id: id, type: registerDocType.rawValue, category: nil) ?? ""
        
        guard let arrDoc = CommonFunctions.convertJSONStringToJSONObject(strDoc) as? [[String : Any]] else {
            return
        }
        
        if let dictDoc = arrDoc.first {
            self.view.makeToastActivity(.center)
            BlockIDSDK.sharedInstance.unregisterDocument(dictDoc: dictDoc) {
                status, error in
                self.view.hideToastActivity()
                self.tableEnrollments.reloadData()
            }
        }
    }
}

extension EnrollMentViewController {
    
    private func enrollPassport(index: Int) {
        let docID = getDocumentID(docIndex: index ,type: .PPT ,category: .Identity_Document) ?? ""
        if (docID != "") {
            let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to unenroll Passport?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.unenrollDocument(registerDocType: .PPT, id: docID)
            }))
            self.present(alert, animated: true)
            return
        }
        let passportType: Enrollments = index == 1 ? .Passport1 : .Passport2
        verifyDocumentWithStoreId(passportType)
    }
}

extension EnrollMentViewController {
    
    private func enrollNationalID() {
        let docID = getDocumentID(docIndex: 1 ,type: .NATIONAL_ID ,category: .Identity_Document) ?? ""
        if (docID != "") {
            let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to unenroll NationalID?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.unenrollDocument(registerDocType: .NATIONAL_ID, id: docID)
            }))
           
            self.present(alert, animated: true)
            return
        }
     
        verifyDocumentWithStoreId(.NationalID)
    }
}

extension EnrollMentViewController {
    private func enrollPin() {
        if BlockIDSDK.sharedInstance.isPinRegistered() {
            let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to unenroll App Pin?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.showPinView(pinActivity: .isRemoving)
            }))
        
            self.present(alert, animated: true)
            return
            
        }
        
        showPinView(pinActivity: .isEnrolling)
    }
}

extension EnrollMentViewController {
    private func enrollDeviceAuth() {
        if !BlockIDSDK.sharedInstance.isDeviceAuthRegisterd() {
           
            BIDAuthProvider.shared.enrollDeviceAuth { (success, error, message) in
                if success {
                    self.tableEnrollments.reloadData()
                    self.view.makeToast("Touch ID / Face ID is now enabled.", duration: 3.0, position: .center)
                    
                } else {
                    if (error as? ErrorResponse)?.code == CustomErrors.kUnauthorizedAccess.code {
                       self.showAppLogin()
                    }
                    if let messageUW = message {
                        if (error as? BiometricError) == .NoID {
                            self.openSettings(title: "Error", message: messageUW)
                        } else {
                            self.showAlertView(title: "", message: messageUW)
                        }
                    }
                }
            }
        }
    }
    
    private func unEnrollDeviceAuth() {
        BIDAuthProvider.shared.unenrollDeviceAuth(completion: { (success, error, message) in
            if success {
                self.view.makeToast("Touch ID / Face ID is now unenrolled from App.", duration: 3.0, position: .center)
                self.tableEnrollments.reloadData()
            } else {
                if (error as? ErrorResponse)?.code == CustomErrors.kUnauthorizedAccess.code {
                    self.showAppLogin()
                }
                if let messageUW = message {
                    self.showAlertView(title: "", message: messageUW)
                }
            }
        })
    }
}

extension EnrollMentViewController {
    private func scanQRCode() {
        self.showQROptions()
    }
}

extension EnrollMentViewController {
    private func recoverMnemonic() {
        let recoverMnemonicVC = self.storyboard?.instantiateViewController(withIdentifier: "RecoverMnemonicsViewController") as! RecoverMnemonicsViewController
        self.navigationController?.pushViewController(recoverMnemonicVC, animated: true)
    }
}

extension EnrollMentViewController {
    private func showLiveID() {
        if !BlockIDSDK.sharedInstance.isLiveIDRegisterd() {
            showLiveIDView()
        }
    }
    
    private func resetApp() {
        let alert = UIAlertController(title: "Warning!", message: "Do you want to reset application?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.resetAppNSDK(ResetSDK.resetAppOptionClicked.message())
            self.showHomeView()
        }))
        
        self.present(alert, animated: true)
        return
    }
}
