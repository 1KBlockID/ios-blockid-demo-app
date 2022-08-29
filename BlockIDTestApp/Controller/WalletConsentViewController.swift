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
    func proposalApproved(isApproved: Bool)
    func signApproved(isApproved: Bool, request: Request)
}
class WalletConsentViewController: UIViewController {

    var proposal: Session.Proposal!
    var isForProposal: Bool!
    var sessionRequest: Request!
    weak var delegate: WalletConsentVCDelegate?

    @IBOutlet weak var viewTitleLbl: UILabel!
    @IBOutlet weak var dAppUrlLbl: UILabel!
    @IBOutlet weak var walletAddressLbl: UILabel!
    @IBOutlet weak var signTransView: UIView!
    @IBOutlet weak var proposalView: UIView!
    
    @IBOutlet weak var fromAddressLbl: UILabel!
    @IBOutlet weak var toAddressLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var gasPriceLbl: UILabel!
    @IBOutlet weak var dataLbl: UILabel!
    @IBOutlet weak var nonceLbl: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        if isForProposal {
            viewTitleLbl.text = "Would you like to connect with your wallet"
            signTransView.isHidden = true
            proposalView.isHidden = false
            dAppUrlLbl.text = proposal.proposer.url
            walletAddressLbl.text = "0x" + BlockIDSDK.sharedInstance.getDID()
        } else {
            viewTitleLbl.text = "Would you like to sign this transaction request"
            signTransView.isHidden = false
            proposalView.isHidden = true
            fromAddressLbl.text = "0x" + BlockIDSDK.sharedInstance.getDID()
            toAddressLbl.text = "0x" + BlockIDSDK.sharedInstance.getDID()
            //FIXME: - With WEB3 - Decode Params and show on labels
            //let params = try! sessionRequest.params.get([EthereumTransaction].self)
        }
    }

    @IBAction func approveTapped(_ sender: Any) {
        if isForProposal {
            self.delegate?.proposalApproved(isApproved: true)
        } else {
            self.delegate?.signApproved(isApproved: true, request: sessionRequest)
        }
        self.dismiss(animated: true)
    }

    @IBAction func rejectTapped(_ sender: Any)  {
        if isForProposal {
            self.delegate?.proposalApproved(isApproved: false)
        } else {
            self.delegate?.signApproved(isApproved: false, request: sessionRequest)
        }
        self.dismiss(animated: true)
    }

}
