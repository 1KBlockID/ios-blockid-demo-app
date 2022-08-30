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

extension WalletConnectViewController {
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
  
}
