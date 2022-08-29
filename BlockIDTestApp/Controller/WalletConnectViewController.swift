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
    private var walletConnectHelper: WalletConnectHelper?
    var sessionItems: [ActiveSessionItem] = []
    var currentProposal: Session.Proposal?
    var selectedIndex: IndexPath?

    @IBOutlet weak var connectTable: UITableView!
    @IBOutlet weak var disconnectBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectTable.register(UINib(nibName: "WalletConnectTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletConnectTableViewCell")
        let metadata = WalletConnectMetadata(
            name: "BlockID Demo",
            description: "1Kosmos WalletConenct Demo",
            url: "example.wallet",
            icons: ["https://www.1kosmos.com/favicon.ico"])
        walletConnectHelper = WalletConnectHelper.init(delegate: self, metadata: metadata)
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
        
    }
}

extension WalletConnectViewController: ScanQRViewDelegate {
    func scannedData(data: String) {
        print("------SCANNED DATA-----")
        print("\(data)")
        walletConnectHelper?.connect(uriCode: data)
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
            cell.selectedCheckImg.image = UIImage(named: "ssnCheck")
            selectedIndex = indexPath
            return
        }
        if selectedIndex.row == indexPath.row {
            cell.selectedCheckImg.image = UIImage(named: "ssnUnCheck")
        } else {
            cell.selectedCheckImg.image = UIImage(named: "ssnCheck")
            let oldcell = tableView.cellForRow(at: selectedIndex) as! WalletConnectTableViewCell
            oldcell.selectedCheckImg.image = UIImage(named: "ssnUnCheck")
        }
        self.selectedIndex = indexPath
    }
}

extension WalletConnectViewController: WalletConnectDelegate {
    
    func receivedSessionProposal(proposal: Session.Proposal?) {
        currentProposal = proposal
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
        DispatchQueue.main.async {
            let consentVC = self.storyboard?.instantiateViewController(withIdentifier: "WalletConsentViewController") as! WalletConsentViewController
            consentVC.sessionRequest = request
            consentVC.isForProposal = false
            consentVC.delegate = self
            self.present(consentVC, animated: true)
        }
    }

    func receivedActiveSessions(sessions: [ActiveSessionItem]) {
        self.sessionItems = sessions
        let alert = UIAlertController(title: "Success", message: "Your wallet has been connected to \(currentProposal?.proposer.url)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
            self.connectTable.reloadData()
        }))
        self.present(alert, animated: true)
    }
    
    func disconnectWalletSession(remainingSession: [ActiveSessionItem]) {
        self.sessionItems = remainingSession
        let alert = UIAlertController(title: "Success", message: "Your wallet has been disconnected", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
            DispatchQueue.main.async { [weak self] in
                self?.connectTable.reloadData()
            }
        }))
        self.present(alert, animated: true)
    }
    
    func receivedError(error: WalletConnectErrors) {
        switch error {
        case .SDK_LOCKED:
            print("SDK is LOCKED-------->")
        case .NOT_CONNECTED:
            print("NOT CONNECTED -------->")
        }
    }
}

extension WalletConnectViewController: WalletConsentVCDelegate {

    func proposalApproved(isApproved: Bool) {
        Task {
            try await self.walletConnectHelper?.responseToProposal(isAccepted: isApproved)
        }
    }
    
    func signApproved(isApproved: Bool, request: Request) {
        self.walletConnectHelper?.signTransaction(isApproved: isApproved, request: request)
    }
}



