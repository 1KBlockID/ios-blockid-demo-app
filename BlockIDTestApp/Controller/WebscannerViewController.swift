//
//  DocumentWebScannerViewController.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 01/06/22.
//

import UIKit
import WebKit
import BlockIDSDK

class WebscannerViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    private var sessionDict: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startwebSDKScan()
        // Do any additional setup after loading the view.
    }
    

   
    @IBAction func doBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    private func startwebSDKScan() {
        
//        guard let linkedUserAccounts = BlockIDSDK.sharedInstance.getLinkedUserAccounts().linkedUsers, !linkedUserAccounts.isEmpty else {
//            self.showAlertView(title: "Error", message: "User onboarding is mandatory. Please add the user and try again.")
//            return
//        }
        
        self.view.makeToastActivity(.center)
        SessionAPI.sharedInstance.fetchServerPublicKey { publicKey in
            
            let sessionRequest = ["tenantDNS": "idpass.1kosmos.net",
                                  "communityName": "default",
                                  "documentType": "dl_object",
                                  "userUID": "aditya001",
                                  "did": BlockIDSDK.sharedInstance.getDID()]
            
            SessionAPI.sharedInstance.createSession(dvcID: AppConsant.dvcID, dict: sessionRequest) { [weak self] object, error in
                guard let weakSelf = self else {return}
                weakSelf.view.hideToastActivity()
                guard error == nil else {
                    return
                }
                if let sessionObj = object {
                    if let sessionObj = object, let webURL = sessionObj.url {
                        weakSelf.webView.navigationDelegate = self
                        let url = URL(string: webURL)!
                        weakSelf.webView.load(URLRequest(url: url))
                        weakSelf.webView.allowsBackForwardNavigationGestures = true
                        weakSelf.sessionDict = ["sessionId": sessionObj.sessionId ?? "",
                                                "dvcID": AppConsant.dvcID ]
                    }
                }
            }
            
        }
        
        
   //linkedUserAccounts[0].userId
        
    }

}

extension WebscannerViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let dict = sessionDict {
            BlockIDSDK.sharedInstance.pollDocumentSession(dict: dict) { success, result, error in
                if success {
                    self.view.makeToast("Document enrolled successfully.", duration: 3.0, position: .center)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.view.makeToast(error?.message, duration: 3.0, position: .center)
                }
            }
        }
    }
}
