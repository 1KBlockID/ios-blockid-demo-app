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

let kReceivedActiveSessions = "receivedActiveSessions"
let kDisconnectWalletSession = "disconnectWalletSession"

let appDelegate = UIApplication.shared.delegate as? AppDelegate
extension AppDelegate: WalletConnectDelegate {
    
    func receivedSessionProposal(proposal: Session.Proposal?) {
        print("<<<< >>>>",#function)
        currentProposal = proposal
        DispatchQueue.main.async {
        if let topVCObj = UIApplication.shared.topMostViewController() {
                let consentVC = topVCObj.storyboard?.instantiateViewController(withIdentifier: "WalletConsentViewController") as! WalletConsentViewController
                consentVC.proposal = proposal
                consentVC.isForProposal = true
                consentVC.delegate = appDelegate
                topVCObj.present(consentVC, animated: true)
            }
        }
    }
    
    func receivedSignTransactionRequest(request: Request) {
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
    
    func receivedActiveSessions(sessions: [ActiveSessionItem]) {
        print("<<<< >>>>",#function,sessions)
        if let topVCObj = UIApplication.shared.topMostViewController() {
            print(topVCObj)
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Success",
                                              message: "Your wallet has been connected to \(self.currentProposal?.proposer.url ?? "")",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok",
                                              style: .default,
                                              handler: {_ in 
                    NotificationCenter.default.post(name: Notification.Name(kReceivedActiveSessions),
                                                    object: nil,
                                                    userInfo: ["sessionItems":sessions])
                }))
                topVCObj.present(alert, animated: true)
            }
        }
    }
    
    func disconnectWalletSession(remainingSession: [ActiveSessionItem]) {
        print("<<<< >>>>",#function)
        if let topVCObj = UIApplication.shared.topMostViewController() {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Success", message: "Your wallet has been disconnected", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
                        NotificationCenter.default.post(name: Notification.Name(kDisconnectWalletSession),
                                                        object: nil,
                                                        userInfo: ["sessionItems":remainingSession])
                }))
                topVCObj.present(alert, animated: true)
            }
        }
    }
    
    func receivedError(error: WalletConnectErrors) {
        print("<<<< >>>>",#function)
        switch error {
        case .SDK_LOCKED:
            print("SDK is LOCKED-------->")
        case .NOT_CONNECTED:
            print("NOT CONNECTED -------->")
        }
    }
}


extension AppDelegate: WalletConsentVCDelegate {

    func proposalApproved(isApproved: Bool) {
        print("<<<< >>>>",#function)
        Task {
            try await walletConnectHelper?.responseToProposal(isAccepted: isApproved)
        }
    }

    func signApproved(isApproved: Bool, request: Request) {
        print("<<<< >>>>",#function)
        walletConnectHelper?.signTransaction(isApproved: isApproved, request: request)
    }
}
