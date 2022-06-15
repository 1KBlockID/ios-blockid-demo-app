//
//  DocumentWebScannerViewController.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 01/06/22.
//

import UIKit
import WebKit
import BlockIDSDK

class WebScannerViewController: UIViewController {

    // MARK: - IBOUTLETS -
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var btnBack: UIButton!
    
    // MARK: - Private properties -
    private var sessionId: String?

    // MARK: - View lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        startwebSDKScan()
    }
       
    // MARK: - IBActions -
    @IBAction func doBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        SessionAPI.sharedInstance.cancelOngoingRequest()
    }
    
    // MARK: - Private methods -
    private func startwebSDKScan() {
        
        self.view.makeToastActivity(.center)
        SessionAPI.sharedInstance.fetchServerPublicKey { (publicKey, error) in
            
            let sessionRequest = ["tenantDNS": "idpass.1kosmos.net",
                                  "communityName": "default",
                                  "documentType": "dl_object",
                                  "userUID": BlockIDSDK.sharedInstance.getDID(),
                                  "did": BlockIDSDK.sharedInstance.getDID()]
            
            SessionAPI.sharedInstance.createSession(dvcID: AppConsant.dvcID, dict: sessionRequest) { [weak self] object, error in
                guard let weakSelf = self else {return}
                weakSelf.view.hideToastActivity()
                guard error == nil else {
                    return
                }
                if let sessionObj = object, let webURL = sessionObj.url {
                    weakSelf.webView.navigationDelegate = self
                    weakSelf.view.makeToastActivity(.center)
                    let url = URL(string: webURL)!
                    weakSelf.webView.load(URLRequest(url: url))
                    weakSelf.webView.allowsBackForwardNavigationGestures = true
                    weakSelf.sessionId = sessionObj.sessionId ?? ""
                }
            }
        }
        
    }
    
    private func verifySession() {
        if let sessionId = sessionId {
            SessionAPI.sharedInstance.fetchServerPublicKey { (publicKey, error) in
                if let publicKey = publicKey, !publicKey.isEmpty {
                    SessionAPI.sharedInstance.verifySession(dvcID: AppConsant.dvcID, sessionID: sessionId, publicKey: publicKey) { result, errorMsg in
                        
                        guard errorMsg == nil else {
                            self.view.makeToast(errorMsg, duration: 3.0, position: .center, title: "Error", completion: {_ in
                                SessionAPI.sharedInstance.cancelOngoingRequest()
                                self.navigationController?.popViewController(animated: true)
                            })
                            return
                        }
                        
                        if let response = result {
                            // register document api...
                            self.view.makeToastActivity(.center)
                            self.btnBack.isEnabled = false
                            self.btnBack.alpha = 0.5
                            
                                if let faceObj = response.liveIdObject["face"] as? String {
                                    let faceImg = CommonFunctions.convertImageFromBase64String(str: faceObj)
                                    let proofedBy = response.liveIdObject["proofedBy"] as? String ?? ""
                                    BlockIDSDK.sharedInstance.registerDocument(obj: response.dlObject, liveIdProofedBy: proofedBy, faceImage: faceImg) { status, error in
                                        DispatchQueue.main.async {
                                            self.view.hideToastActivity()
                                            self.btnBack.isEnabled = true
                                            self.btnBack.alpha = 1.0
                                            if !status {
                                                // FAILED
                                                self.view.makeToast(error?.message, duration: 3.0, position: .center, title: "Error", completion: {_ in
                                                    SessionAPI.sharedInstance.cancelOngoingRequest()
                                                    self.navigationController?.popViewController(animated: true)
                                                })
                                                return
                                            }
                                            // SUCCESS
                                            self.view.makeToast("Drivers License enrolled successfully.", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
                                                self.navigationController?.popViewController(animated: true)
                                            })
                                        }
                                    }
                            }
                        }
                    }
                } else {
                    self.view.makeToast(error, duration: 3.0, position: .center, title: "Error", completion: {_ in
                        SessionAPI.sharedInstance.cancelOngoingRequest()
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }

}

// MARK: - Extension -
extension WebScannerViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.hideToastActivity()
        verifySession()
    }
}
