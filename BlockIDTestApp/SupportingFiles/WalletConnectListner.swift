//
//  WalletConnectListner.swift
//  BlockIDTestApp
//
//  Created by Prasanna Kumar Gupta on 29/08/22.
//

import Foundation
import BlockIDSDK
import WalletConnectSign
import UIKit

let kOnSessionSettleResponse = "onSessionSettleResponse"
let kOnSessionDisconnect = "onSessionDisconnect"
let kOnSessionProposal = "onSessionProposal"

let appDelegate = UIApplication.shared.delegate as? AppDelegate
extension AppDelegate: WalletConnectDelegate {
    
    func onSessionProposal(sessionProposal: Session.Proposal?) {
        currentProposal = sessionProposal
        DispatchQueue.main.async {
        if let topVCObj = UIApplication.shared.topMostViewController() {
                let consentVC = topVCObj.storyboard?.instantiateViewController(withIdentifier: "WalletConsentViewController") as! WalletConsentViewController
                consentVC.proposal = sessionProposal
                consentVC.isForProposal = true
                consentVC.delegate = appDelegate
                topVCObj.present(consentVC, animated: true)
            }
            NotificationCenter.default.post(name: Notification.Name(kOnSessionProposal), object: nil)
        }
    }
    
    func onSessionRequest(request: Request) {
        if let topVCObj = UIApplication.shared.topMostViewController() {
            DispatchQueue.main.async {
                let sessions = appDelegate?.sessionItems.filter({$0.topic == request.topic})
                let consentVC = topVCObj.storyboard?.instantiateViewController(withIdentifier: "WalletConsentViewController") as! WalletConsentViewController
                consentVC.sessionRequest = request
                consentVC.isForProposal = false
                consentVC.delegate = appDelegate
                consentVC.sessionUrl = sessions?[0].dappURL
                topVCObj.present(consentVC, animated: true)
            }
        }
    }
    
    func onSessionSettleResponse(sessions: [ActiveSessionItem]) {
        appDelegate?.sessionItems = sessions
        NotificationCenter.default.post(name: Notification.Name(kOnSessionSettleResponse),
                                        object: nil,
                                        userInfo: ["sessionItems":sessions])
    }
    
    func onSessionDisconnect(remainingSession: [ActiveSessionItem]) {
        if let topVCObj = UIApplication.shared.topMostViewController() {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Success", message: "Your wallet has been disconnected", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                }))
                topVCObj.present(alert, animated: true)
                NotificationCenter.default.post(name: Notification.Name(kOnSessionDisconnect),
                                                object: nil,
                                                userInfo: ["sessionItems":remainingSession])
            }
        }
    }
    
    func onError(error: Error) {
        if let topVCObj = UIApplication.shared.topMostViewController() {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            topVCObj.present(alert, animated: true)
        }
    }
}


extension AppDelegate: WalletConsentVCDelegate {
    
    func proposalApproved(isApproved: Bool, sessionProposal: Session.Proposal) {
        if isApproved {
            Task {
                try await walletConnectHelper?.approveConnection(sessionProposal: sessionProposal)
            }
        } else {
            Task {
                try await walletConnectHelper?.rejectConnection(sessionProposal: sessionProposal)
            }
        }
    }
    
    func signApproved(isApproved: Bool, request: Request) {
        if isApproved {
            walletConnectHelper?.approveSession(request: request)
        } else {
            walletConnectHelper?.rejectSession(request: request)
        }
    }
}
