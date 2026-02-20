//
//  NationalIDViewController.swift.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import AVFoundation
import BlockID
import Toast_Swift
  
class NationalIDViewController: UIViewController {

    private let kIDCardFailedMessage = "We couldn’t complete the verification of the document. Please try again."
    private let kSessionExpiredOrTimeout = "This verification session is no longer available. You need to begin the journey again."
    private var liveIdFace: String!
    private var proofedBy: String!
    var uid: String?

    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var imgLoader: UIImageView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start loader spin
        self.rotateView(imgLoader)
        
        // Start ID CARD loading
        startNationalIDScanning()
    }
    
    private func goBack(isFailed: Bool? = false) {
        if let viewControllers = navigationController?.viewControllers {
            if isFailed ?? false {
                for controller in viewControllers where controller is DocumentScannerWithUIdVC {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigationController?.popToViewController(controller, animated: true)
                    }
                    return
                }
            } else {
                for controller in viewControllers where controller is EnrollMentViewController {
                    self.navigationController?.popToViewController(controller, animated: true)
                    return
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    private func startNationalIDScanning() {
        self.showDocumentScannerFor(.IDCARD, self.uid, self)
    }

    private func setNationaID(withNIDData nid: [String : Any], _ sessionId: String?) {
        var dic = nid
        dic["category"] = RegisterDocCategory.Identity_Document.rawValue
        dic["type"] = RegisterDocType.NATIONAL_ID.rawValue
        dic["id"] = nid["id"] as! String
        
        if !BlockIDSDK.sharedInstance.isLiveIDRegistered() {
            self.registerWithLiveID(dic: dic, sessionId)
        } else {
            self.registerWithOutLiveID(dic: dic, sessionId)
        }
    }
    
    private func registerWithLiveID(dic: [String: Any], _ sessionId: String?) {
        guard let imgB64Str = self.liveIdFace,
              let imgdata = Data(base64Encoded: imgB64Str,
                                 options: .ignoreUnknownCharacters),
              let img = UIImage(data: imgdata) else {
            return
        }
        
        let mobileDocumentId = "nationalid_with_live_id_" + UUID().uuidString
        BlockIDSDK.sharedInstance.registerDocument(obj: dic,
                                                   liveIdProofedBy: self.proofedBy,
                                                   faceImage: img,
                                                   mobileSessionId: sessionId,
                                                   mobileDocumentId: mobileDocumentId)
        { [self] (status, error) in
            DispatchQueue.main.async {
                if !status {
                    // FAILED
                    self.view.makeToast(error?.message,
                                        duration: 3.0,
                                        position: .center,
                                        title: "Error!",
                                        completion: {_ in
                        self.goBack(isFailed: true)
                    })
                    return
                }
                // SUCCESS
                self.view.makeToast("National ID enrolled successfully.",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Thank you!", completion: {_ in
                    self.goBack()
                })
            }
        }
    }
    
    private func registerWithOutLiveID(dic: [String: Any], _ sessionId: String?) {
        let mobileDocumentId = "nationalid_" + UUID().uuidString
        BlockIDSDK.sharedInstance.registerDocument(obj: dic,
                                                   mobileSessionId: sessionId,
                                                   mobileDocumentId: mobileDocumentId) { [self] (status, error) in
            DispatchQueue.main.async {
                if !status {
                    // FAILED
                    self.view.makeToast(error?.message,
                                        duration: 3.0,
                                        position: .center,
                                        title: "Error!",
                                        completion: {_ in
                        self.goBack(isFailed: true)
                    })
                    return
                }
                // SUCCESS
                self.view.makeToast("National ID enrolled successfully.",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Thank you!", completion: {_ in
                    self.goBack()
                })
            }
        }
    }
}

// MARK: - DocumentSessionScanDelegate -
extension NationalIDViewController: DocumentScanDelegate {
    
    func onDocumentScanResponse(status: Bool, document: String?, sessionID: String?, error: ErrorResponse?) {
        
        if !status {
            if error?.code == CustomErrors.kUnauthorizedAccess.code {
                self.showAppLogin()
                return
            }
            
            if error?.code == CustomErrors.License.MODULE_NOT_ENABLED.code {
                let localizedMessage = "MODULE_NOT_ENABLED".localizedMessage(CustomErrors.License.MODULE_NOT_ENABLED.code)
                self.showAlertAndMoveBack(title: "Error", message: localizedMessage)
                return
            }
            
            if error?.code == CustomErrors.DocumentScanner.CANCELED.code { // Cancelled
                self.goBack(isFailed: true)
                return
            }
            
            self.showAlertAndMoveBack(title: "Error",
                                      message: error?.message ?? kIDCardFailedMessage)
            return
        }
        
        guard let documentObject = document,
              !documentObject.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        guard let dictDocObject = CommonFunctions.jsonStringToDic(from: documentObject) else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        guard let sessionResult = dictDocObject["sessionResult"] as? String,
              !sessionResult.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        let failedStatuses: Set<String> = ["FAILED", "EXPIRED", "ABANDONED"]
        if failedStatuses.contains(sessionResult.uppercased()) {
            var title = "Error"
            var msg = ""
            switch sessionResult.uppercased() {
            case "FAILED":
                // Update with dynamic message of errorInfo
                if let dictErrorInfo = (dictDocObject["errorInfo"] as? [String: Any]),
                   let reasonCode = dictErrorInfo["reasonCode"] as? String,
                   let error = IDVError(rawValue: reasonCode) {

                    msg = error.localizedDescription
                } else {
                    msg = kIDCardFailedMessage
                }
            case "EXPIRED":
                title = "Session Expired"
                msg = kSessionExpiredOrTimeout
            case "ABANDONED":
                title = "Scanning Timeout"
                msg = kSessionExpiredOrTimeout
            default:
                debugPrint("unknown status")
            }
            self.showAlertAndMoveBack(title: title,
                                      message: msg)
            return
        }
        
        guard let token = dictDocObject["token"] as? String,
              !token.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        guard var dictIdcardObject = dictDocObject["document"] as? [String: Any] else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        guard let proof_jwt = dictIdcardObject["proof_jwt"] as? String,
              !proof_jwt.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        
        if let liveIdObj = dictDocObject["liveId"] as? [String: Any] {
            self.liveIdFace = liveIdObj["face"] as? String
            self.proofedBy = liveIdObj["proofedBy"] as? String
        }

        dictIdcardObject["proof"] = proof_jwt
        dictIdcardObject["certificate_token"] = token
       
        if shouldEnrollOtherDocumentOnNationalIdScan(sessionResult, dictDocObject, dictIdcardObject, sessionID ?? "") {
            return
        }
        self.setNationaID(withNIDData: dictIdcardObject, sessionID)
    }
    
    private func shouldEnrollOtherDocumentOnNationalIdScan(_ sessionResult: String,
                                                           _ dictDocObject: [String: Any],
                                                           _ currentDocumentObj: [String: Any],
                                                           _ sessionId: String)  -> Bool {
        if sessionResult.uppercased() == "SUCCESS",
                  let document = (dictDocObject["document"] as? [String: Any]),
                    let documentType = document["documentType"] as? String {
            // If status is success but enrolled documentType is different then do not save the doc and show error..
            // ...with option to save that document
            if documentType.uppercased() == "PASSPORT" {
                let docID = getDocumentID(docIndex: 1 ,type: .PPT ,category: .Identity_Document) ?? ""
                if docID != "" { // Already Enrolled, show alert and move back
                    self.showAlertAndMoveBack(title: "Error",
                                              message: "Passport is already enrolled.")
                } else { // Proceess enrollment
                    let alert = UIAlertController(title: "Passport Identified",
                                                  message: "We identified that you have scanned a Passport. Do you want to register the Passport in this application?",
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: { alert in
                        self.goBack(isFailed: true)
                    }))
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                        // Try enrolling passport
                        self.processPassportEnrolment(currentDocumentObj, sessionId: sessionId)
                    }))
                    self.present(alert, animated: true)
                }
            } else if documentType.uppercased() == "DL" {
                let docID = getDocumentID(docIndex: 1 ,type: .DL ,category: .Identity_Document) ?? ""
                if docID != "" { // Already Enrolled, show alert and move back
                    self.showAlertAndMoveBack(title: "Error",
                                              message: "Drivers License is already enrolled.")
                } else { // Proceess enrollment
                    let alert = UIAlertController(title: "Drivers License Identified",
                                                  message: "We identified that you have scanned a Drivers License. Do you want to register the Drivers License in this application?",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: { alert in
                        self.goBack(isFailed: true)
                    }))
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                        // Try enrolling Drivers License
                        self.processDLEnrolment(currentDocumentObj, sessionId: sessionId)
                    }))
                    self.present(alert, animated: true)
                }
            }
            return true
        }
        return false
    }
    
    private func processPassportEnrolment(_ document: [String: Any], sessionId: String) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
         if let ppVC = storyBoard.instantiateViewController(withIdentifier: "PassportViewController") as? PassportViewController {
             ppVC.uid = self.uid
             ppVC.shouldEnrolNIDAsPPT = true
             ppVC.dictPPT = document
             ppVC.sessionId = sessionId
             self.navigationController?.pushViewController(ppVC, animated: true)
         }
    }
    
    private func processDLEnrolment(_ document: [String: Any], sessionId: String) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let dlVC = storyBoard.instantiateViewController(withIdentifier: "DriverLicenseViewController") as? DriverLicenseViewController {
            dlVC.uid = self.uid
            dlVC.shouldEnrolNIDAsDL = true
            dlVC.dictDL = document
            dlVC.sessionId = sessionId
            self.navigationController?.pushViewController(dlVC, animated: true)
        }
    }
    
    private func showAlertAndMoveBack(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.goBack(isFailed: true)
        }))
        self.present(alert, animated: true)
    }
}

