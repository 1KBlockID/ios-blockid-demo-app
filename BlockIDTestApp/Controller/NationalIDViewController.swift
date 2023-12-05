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

    private let kIDCardFailedMessage = "National ID failed to scan."
    
    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var imgLoader: UIImageView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start loader spin
        self.rotateView(imgLoader)
        
        // Start ID CARD loading
        startNationalIDScanning()
    }
    
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func startNationalIDScanning() {
        //1. Check for Camera Permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if !response {
                //2. Show Alert
                DispatchQueue.main.async {
                    self.alertForCameraAccess()
                }
            } else {
                DispatchQueue.main.async {
                    self.showDocumentScannerFor(.IDCARD, self)
                }
            }
        }
        
    }

    private func setNationaID(withNIDData nid: [String : Any], token: String) {
        var dic = nid
        dic["category"] = RegisterDocCategory.Identity_Document.rawValue
        dic["type"] = RegisterDocType.NATIONAL_ID.rawValue
        dic["id"] = nid["id"] as! String
        BlockIDSDK.sharedInstance.registerDocument(obj: dic,
                                                   sigToken: token) { [self] (status, error) in
            DispatchQueue.main.async {
                if !status {
                    // FAILED
                    if error?.code == CustomErrors.kLiveIDMandatory.code {
                        DocumentStore.sharedInstance.setData(documentData: dic)
                        self.goBack()
                        self.showLiveIDView()
                        return
                    }
                    
                    self.view.makeToast(error?.message,
                                        duration: 3.0,
                                        position: .center,
                                        title: "Error!",
                                        completion: {_ in
                        self.goBack()
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
    
    func onDocumentScanResponse(status: Bool, document: String?, error: ErrorResponse?) {
        
        if error?.code == CustomErrors.kUnauthorizedAccess.code {
            self.showAppLogin()
        }
        
        if error?.code == CustomErrors.License.MODULE_NOT_ENABLED.code {
            let localizedMessage = "MODULE_NOT_ENABLED".localizedMessage(CustomErrors.License.MODULE_NOT_ENABLED.code)
            self.showAlertAndMoveBack(title: "Error", message: localizedMessage)
            return
        }
        
        if error?.code == CustomErrors.DocumentScanner.CANCELED.code { // Cancelled
            self.goBack()
        }
        
        if error?.code == CustomErrors.DocumentScanner.TIMEOUT.code {
            self.showAlertAndMoveBack(title: "Error",
                                      message: "Scanning time exceeded. To continue, please restart the scanning process.")
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
        guard let responseStatus = dictDocObject["responseStatus"] as? String,
              !responseStatus.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        if responseStatus.uppercased() == "FAILED" {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        guard let token = dictDocObject["token"] as? String,
              !token.isEmpty else {
            self.showAlertAndMoveBack(title: "Error",
                                      message: kIDCardFailedMessage)
            return
        }
        guard var dictIdcardObject = dictDocObject["idcard_object"] as? [String: Any] else {
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
        
        dictIdcardObject["proof"] = proof_jwt
        dictIdcardObject["certificate_token"] = token
        self.setNationaID(withNIDData: dictIdcardObject, token: "")
    }

    private func showAlertAndMoveBack(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.goBack()
        }))
        self.present(alert, animated: true)
    }
}

