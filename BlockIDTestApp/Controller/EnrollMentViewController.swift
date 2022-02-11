//
//  EnrollMentViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import BlockIDSDK
import Toast_Swift
import UIKit


public enum Enrollments: String {
    case DriverLicense = "Driver License 1"
    case Passport1  = "Passport 1"
    case Passport2  = "Passport 2"
    case NationalID  = "National ID 1"
    case SSN = "Verify SSN"
    case Pin  = "App Pin"
    case DeviceAuth  = "Device Auth"
    case LiveID  = "LiveID"
    case LiveID_liveness = "LiveID (with liveness check)"
    case LoginWithQR  = "Login With QR"
    case RecoverMnemonics  = "Recover Mnemonics"
    case resetApp  = "Reset App"
}

class EnrollMentViewController: UIViewController {
    
    var enrollmentArray = [Enrollments.DriverLicense,
                           Enrollments.Passport1,
                           Enrollments.Passport2,
                           Enrollments.NationalID,
                           Enrollments.SSN,
                           Enrollments.Pin,
                           Enrollments.DeviceAuth,
                           Enrollments.LiveID,
                           Enrollments.LiveID_liveness,
                           Enrollments.LoginWithQR,
                           Enrollments.RecoverMnemonics,
                           Enrollments.resetApp]
    
    @IBOutlet weak var tableEnrollments: UITableView!
    @IBOutlet weak var lblSDKVersion: UILabel!
    var enrollTableViewReuseIdentifier = "EnrollmentTableViewCell"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let version = BlockIDSDK.sharedInstance.getVersion() {
            if let buildNo = version.components(separatedBy: ".").max(by: {$1.count > $0.count}) {
                let versionArr = version.components(separatedBy: ".")
                var sdkVersion = ""
                for index in 0...versionArr.count - 1 {
                    if versionArr[index] != buildNo {
                        if index < versionArr.count - 2 {
                            sdkVersion += versionArr[index] + "."
                        } else {
                            sdkVersion += versionArr[index]
                        }
                    }
                }
                lblSDKVersion.text = "SDK Version: " + sdkVersion + " \( "(" + buildNo + ")"  )"
            }
        }
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
        case Enrollments.DriverLicense.rawValue:
            enrollDL()
        case Enrollments.Passport1.rawValue:
            enrollPassport(index: 1)
        case Enrollments.Passport2.rawValue:
            enrollPassport(index: 2)
        case Enrollments.NationalID.rawValue:
            enrollNationalID()
        case Enrollments.SSN.rawValue:
            showSSNVerificationView()
        case Enrollments.Pin.rawValue:
            enrollPin()
        case Enrollments.DeviceAuth.rawValue:
            enrollDeviceAuth()
        case Enrollments.LiveID.rawValue:
            enrollLiveID(isLivenessNeeded: false)
        case Enrollments.LiveID_liveness.rawValue:
            enrollLiveID(isLivenessNeeded: true)
        case Enrollments.LoginWithQR.rawValue:
            scanQRCode()
        case Enrollments.RecoverMnemonics.rawValue:
            recoverMnemonic()
        case Enrollments.resetApp.rawValue:
            resetApp()
        default:
            return
        }
    }
    
}

extension EnrollMentViewController {
    
    private func enrollDL() {
        let docID = getDocumentID(docIndex: 1 ,type: .DL ,category: .Identity_Document) ?? ""
        if  !docID.isEmpty {
            let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to unenroll Driver License", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.unenrollDocument(registerDocType: .DL, id: docID)
            }))
            self.present(alert, animated: true)
            return
        }
        showDLView()
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
            let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to unenroll Passport", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.unenrollDocument(registerDocType: .PPT, id: docID)
            }))
            self.present(alert, animated: true)
            return
        }
        showPassportView()
    }
}

extension EnrollMentViewController {
    
    private func enrollNationalID() {
        let docID = getDocumentID(docIndex: 1 ,type: .NATIONAL_ID ,category: .Identity_Document) ?? ""
        if (docID != "") {
            let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to unenroll NationalID", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                self.unenrollDocument(registerDocType: .NATIONAL_ID, id: docID)
            }))
            self.present(alert, animated: true)
            return
        }
        showNationalIDView()
    }
    
}

extension EnrollMentViewController {
    private func enrollPin() {
        if BlockIDSDK.sharedInstance.isPinRegistered() {
            let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to unenroll App Pin", preferredStyle: .alert)

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
                    self.view.makeToast("TouchID / FaceID is now enabled", duration: 3.0, position: .center)
                    
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
                self.view.makeToast("TouchID / FaceID is now unenrolled from App", duration: 3.0, position: .center)
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
    private func enrollLiveID(isLivenessNeeded: Bool) {
        if !BlockIDSDK.sharedInstance.isLiveIDRegisterd() {
            showLiveIDView(isLivenessNeeded: isLivenessNeeded)
        }
    }
    
    private func resetApp() {
        let alert = UIAlertController(title: "Warning!", message: "Do you want to reset application", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.resetAppNSDK()
            self.showHomeView()
        }))
        self.present(alert, animated: true)
        return
       
    }
}

