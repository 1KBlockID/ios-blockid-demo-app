//
//  WalletConsentViewController.swift
//  BlockIDTestApp
//
//  Created by Kuldeep Choudhary on 26/08/22.
//

import UIKit
import WalletConnectSign
import BlockIDSDK

protocol WalletConsentVCDelegate: AnyObject {
    func approved(isApproved: Bool)
}
class WalletConsentViewController: UIViewController {

    var proposal: Session.Proposal!
    weak var delegate: WalletConsentVCDelegate?

    @IBOutlet weak var dAppUrlLbl: UILabel!
    @IBOutlet weak var walletAddressLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dAppUrlLbl.text = proposal.proposer.url
        walletAddressLbl.text = "0x" + BlockIDSDK.sharedInstance.getDID()
    }

    @IBAction func approveTapped(_ sender: Any) {
        self.delegate?.approved(isApproved: true)
        self.dismiss(animated: true)
    }

    @IBAction func rejectTapped(_ sender: Any)  {
        self.delegate?.approved(isApproved: false)
            self.dismiss(animated: true)
    }

}
