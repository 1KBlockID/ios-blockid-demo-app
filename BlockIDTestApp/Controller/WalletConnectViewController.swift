//
//  WalletConnectViewController.swift
//  BlockIDTestApp
//
//  Created by Kuldeep Choudhary on 24/08/22.
//

import UIKit
import BlockIDSDK
import WalletConnectSign
import WalletConnectUtils
import Combine

class WalletConnectViewController: UIViewController {

    var WalletConnectCellIdentifier = "WalletConnectTableViewCell"
    var sessionItems: [ActiveSessionItem] = []
    var selectedIndex: IndexPath?
    private var isProposalReceived = false

    @IBOutlet weak var connectTable: UITableView!
    @IBOutlet weak var disconnectBtn: UIButton!
    deinit {
      NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedActiveSessions(notification:)), name: Notification.Name(kReceivedActiveSessions), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.disconnectWalletSession(notification:)), name: Notification.Name(kDisconnectWalletSession), object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.disconnectBtn.isHidden = true
        connectTable.register(UINib(nibName: "WalletConnectTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletConnectTableViewCell")
        addObservers()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func connectDAppTapped(_ sender: Any) {
        let scanQRVC = self.storyboard?.instantiateViewController(withIdentifier: "ScanQRViewController") as! ScanQRViewController
        scanQRVC.delegate = self
        self.present(scanQRVC, animated: true)
    }
    
    @IBAction func disconnectTapped(_ sender: Any) {
        guard let indexpath = selectedIndex else {
            let alert = UIAlertController(title: "Error", message: "No DApp selected!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        walletConnectHelper?.disconnect(session: sessionItems[indexpath.row])
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            self.sessionItems = self.walletConnectHelper?.getActiveSessions() ?? []
            self.disconnectWalletSession(remainingSession: self.sessionItems)
        })
    }
}

extension WalletConnectViewController: ScanQRViewDelegate {
    func scannedData(data: String) {
        print("------SCANNED DATA-----")
        print("\(data)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            appDelegate?.walletConnectHelper?.connect(uriCode: data)
        }
    }
}

extension WalletConnectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WalletConnectCellIdentifier, for: indexPath) as! WalletConnectTableViewCell
        cell.setupCell(item: sessionItems[indexPath.row])
        return cell
    }
    
}

extension WalletConnectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WalletConnectTableViewCell
        
        guard let selectedIndex = selectedIndex else {
            cell.selectedCheckImg.image = UIImage(named: "iconChecked")
            selectedIndex = indexPath
            return
        }
        if selectedIndex.row == indexPath.row {
            cell.selectedCheckImg.image = UIImage(named: "iconUncheck")
        } else {
            cell.selectedCheckImg.image = UIImage(named: "iconChecked")
            let oldcell = tableView.cellForRow(at: selectedIndex) as! WalletConnectTableViewCell
            oldcell.selectedCheckImg.image = UIImage(named: "iconUncheck")
        }
        self.selectedIndex = indexPath
    }
}

extension WalletConnectViewController: WalletConnectDelegate {
    @objc func receivedActiveSessions(notification: Notification) {
        print("<<<<<<<<< receivedActiveSessions",notification.userInfo?["sessionItems"] as Any)
        self.sessionItems = notification.userInfo?["sessionItems"] as? [ActiveSessionItem] ?? []
        self.connectTable.reloadData()
    }

    @objc func disconnectWalletSession(notification: Notification) {
        print("<<<<<<<<< disconnectWalletSession",notification.userInfo?["sessionItems"] as Any)
        self.sessionItems = notification.userInfo?["sessionItems"] as? [ActiveSessionItem] ?? []
        self.connectTable.reloadData()
    }
    
    func receivedSessionProposal(proposal: Session.Proposal?) {
        currentProposal = proposal
        isProposalReceived = true
        print("---CURRENT PROPOSAL---\n \(currentProposal.debugDescription)")
        DispatchQueue.main.async {
            let consentVC = self.storyboard?.instantiateViewController(withIdentifier: "WalletConsentViewController") as! WalletConsentViewController
            consentVC.proposal = proposal
            consentVC.isForProposal = true
            consentVC.delegate = self
            self.present(consentVC, animated: true)
        }
    }
    
    func receivedSignTransactionRequest(request: Request) {
        print("--Transaction request---\n \(request)")
        let sessions = sessionItems.filter({$0.topic == request.topic})
        DispatchQueue.main.async {
            let consentVC = self.storyboard?.instantiateViewController(withIdentifier: "WalletConsentViewController") as! WalletConsentViewController
            consentVC.sessionRequest = request
            consentVC.isForProposal = false
            consentVC.sessionUrl = sessions[0].dappURL
            consentVC.delegate = self
            self.present(consentVC, animated: true)
        }
    }

    func receivedActiveSessions(sessions: [ActiveSessionItem]) {
        self.sessionItems = sessions
        if isProposalReceived {
            let alert = UIAlertController(title: "Success", message: "Your wallet has been connected to \(currentProposal?.proposer.url ?? "DApp")", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
                self.connectTable.reloadData()
            }))
            self.present(alert, animated: true)
        } else {
            DispatchQueue.main.async {
                self.connectTable.reloadData()
            }
        }
        if self.sessionItems.count != 0 {
            self.disconnectBtn.isHidden = false
        }

    }
    
    func disconnectWalletSession(remainingSession: [ActiveSessionItem]) {
        self.sessionItems = remainingSession
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Success", message: "Your wallet has been disconnected", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
                self?.connectTable.reloadData()
                if self?.sessionItems.count != 0 {
                    self?.disconnectBtn.isHidden = false
                } else {
                    self?.disconnectBtn.isHidden = true
                }
            }))
            self?.present(alert, animated: true)
        }
    }
    
    func receivedError(error: WalletConnectErrors) {
        switch error {
        case .SDK_LOCKED:
            print("SDK is LOCKED-------->")
        case .NOT_CONNECTED:
            let alert = UIAlertController(title: "Error", message: "Not able to connect", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
