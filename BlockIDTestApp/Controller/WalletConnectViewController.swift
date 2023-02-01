//
//  WalletConnectViewController.swift
//  BlockIDTestApp
//
//  Created by Kuldeep Choudhary on 24/08/22.
//

import UIKit
import BlockID
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onSessionSettleResponse(notification:)),
                                               name: Notification.Name(kOnSessionSettleResponse),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onSessionDisconnect(notification:)),
                                               name: Notification.Name(kOnSessionDisconnect),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onSessionProposal(notification:)),
                                               name: Notification.Name(kOnSessionProposal),
                                               object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectTable.register(UINib(nibName: "WalletConnectTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletConnectTableViewCell")
        addObservers()
        self.sessionItems = appDelegate?.walletConnectHelper?.getActiveSessions() ?? []
        if self.sessionItems.count != 0 {
            self.disconnectBtn.isHidden = false
        } else {
            self.disconnectBtn.isHidden = true
        }
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
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        appDelegate?.walletConnectHelper?.disconnect(session: sessionItems[indexpath.row])
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            self.sessionItems = appDelegate?.walletConnectHelper?.getActiveSessions() ?? []
            self.manageDisconnectSession(remainingSessions: self.sessionItems)
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Success", message: "Your wallet has been disconnected", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                }))
                self.present(alert, animated: true)
            }
        })
    }
}

extension WalletConnectViewController: ScanQRViewDelegate {
    func scannedData(data: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            appDelegate?.walletConnectHelper?.connect(uri: data)
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

// MARK: - WalletConnectDelegate Listeners -
extension WalletConnectViewController {
    @objc func onSessionProposal(notification: Notification) {
        isProposalReceived = true
    }
    
    @objc func onSessionSettleResponse(notification: Notification) {
        self.sessionItems = notification.userInfo?[kSessionItems] as? [ActiveSessionItem] ?? []
        if isProposalReceived {
            let alert = UIAlertController(title: "Success", message: "Your wallet has been connected to \(appDelegate?.currentProposal?.proposer.url ?? "DApp")", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
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

    fileprivate func manageDisconnectSession(remainingSessions: [ActiveSessionItem]) {
        DispatchQueue.main.async {
            self.connectTable.reloadData()
            if self.sessionItems.count != 0 {
                self.disconnectBtn.isHidden = false
            } else {
                self.disconnectBtn.isHidden = true
            }
        }
    }
    
    @objc func onSessionDisconnect(notification: Notification) {
        self.sessionItems = notification.userInfo?[kSessionItems] as? [ActiveSessionItem] ?? []
        manageDisconnectSession(remainingSessions: self.sessionItems)
    }
}
