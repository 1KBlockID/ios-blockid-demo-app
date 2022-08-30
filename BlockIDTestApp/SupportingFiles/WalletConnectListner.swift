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
        print("<<<< >>>>",#function)
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
        print("<<<< >>>>",#function)
        print("--Transaction request---\n \(request)")
        if let topVCObj = UIApplication.shared.topMostViewController() {
            DispatchQueue.main.async {
                let consentVC = topVCObj.storyboard?.instantiateViewController(withIdentifier: "WalletConsentViewController") as! WalletConsentViewController
                consentVC.sessionRequest = request
                consentVC.isForProposal = false
                consentVC.delegate = appDelegate
                topVCObj.present(consentVC, animated: true)
            }
        }
    }
    
    func onSessionSettleResponse(sessions: [ActiveSessionItem]) {
        print("<<<< >>>>",#function,sessions)
        NotificationCenter.default.post(name: Notification.Name(kOnSessionSettleResponse),
                                        object: nil,
                                        userInfo: ["sessionItems":sessions])
    }
    
    func onSessionDisconnect(remainingSession: [ActiveSessionItem]) {
        print("<<<< >>>>",#function)
        if let topVCObj = UIApplication.shared.topMostViewController() {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Success", message: "Your wallet has been disconnected", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
                        NotificationCenter.default.post(name: Notification.Name(kOnSessionDisconnect),
                                                        object: nil,
                                                        userInfo: ["sessionItems":remainingSession])
                }))
                topVCObj.present(alert, animated: true)
            }
        }
    }
    
    func onError(error: Error) {
        print("<<<< >>>>",#function)
        if let topVCObj = UIApplication.shared.topMostViewController() {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            topVCObj.present(alert, animated: true)
        }
    }
}


extension AppDelegate: WalletConsentVCDelegate {
    
    func proposalApproved(isApproved: Bool, sessionProposal: Session.Proposal) {
        print("<<<< >>>>",#function)
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
        print("<<<< >>>>",#function)
        if isApproved {
            walletConnectHelper?.approveSession(request: request)
        } else {
            walletConnectHelper?.rejectSession(request: request)
        }
    }
}
