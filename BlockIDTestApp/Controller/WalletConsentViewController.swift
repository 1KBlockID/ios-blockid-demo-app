//
//  WalletConsentViewController.swift
//  BlockIDTestApp
//
//  Created by Kuldeep Choudhary on 26/08/22.
//

import UIKit
import WalletConnectSign
import BlockID

protocol WalletConsentVCDelegate: AnyObject {
    func proposalApproved(isApproved: Bool, sessionProposal: Session.Proposal)
    func signApproved(isApproved: Bool, request: Request)
}
class WalletConsentViewController: UIViewController {

    var proposal: Session.Proposal!
    var isForProposal: Bool!
    var sessionRequest: Request!
    var sessionUrl: String!
    weak var delegate: WalletConsentVCDelegate?

    @IBOutlet weak var viewTitleLbl: UILabel!
    @IBOutlet weak var dAppUrlLbl: UILabel!
    @IBOutlet weak var walletAddressLbl: UILabel!
    @IBOutlet weak var signTransView: UIView!
    @IBOutlet weak var proposalView: UIView!
    @IBOutlet weak var personalSignView: UIView!
    
    @IBOutlet weak var fromAddressLbl: UILabel!
    @IBOutlet weak var toAddressLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var gasPriceLbl: UILabel!
    @IBOutlet weak var dataLbl: UILabel!
    @IBOutlet weak var nonceLbl: UILabel!
    @IBOutlet weak var signMsgLbl: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if isForProposal {
            viewTitleLbl.text = "Would you like to connect with your wallet"
            signTransView.isHidden = true
            personalSignView.isHidden = true
            proposalView.isHidden = false
            dAppUrlLbl.text = proposal.proposer.url
            walletAddressLbl.text = "0x" + BlockIDSDK.sharedInstance.getDID()
        } else {
            viewTitleLbl.text = "Would you like to sign transaction request for \n \(sessionUrl ?? "DApp")"
            dAppUrlLbl.isHidden = true
            if sessionRequest.method == "personal_sign" {
                personalSignView.isHidden = false
                signTransView.isHidden = true
                proposalView.isHidden = true
                let params = sessionRequest.params.value as! [String]
                let msg = params[0].convertHexToString()
                signMsgLbl.text = msg
            } else {
                personalSignView.isHidden = true
                signTransView.isHidden = false
                proposalView.isHidden = true
                let params = sessionRequest.params.value as! [[String: String]]
                fromAddressLbl.text = params[0]["from"]
                toAddressLbl.text = params[0]["to"]
                valueLbl.text = params[0]["value"]
                gasPriceLbl.text = params[0]["gasPrice"]
                dataLbl.text = params[0]["data"]
                nonceLbl.text = params[0]["nonce"]
            }
        }
    }

    
    @IBAction func approveTapped(_ sender: Any) {
        if isForProposal {
            self.delegate?.proposalApproved(isApproved: true, sessionProposal: self.proposal)
        } else {
            self.delegate?.signApproved(isApproved: true, request: sessionRequest)
        }
        self.dismiss(animated: true)
    }

    @IBAction func rejectTapped(_ sender: Any)  {
        if isForProposal {
            self.delegate?.proposalApproved(isApproved: false, sessionProposal: self.proposal)
        } else {
            self.delegate?.signApproved(isApproved: false, request: sessionRequest)
        }
        self.dismiss(animated: true)
    }

}

extension String {
    func convertHexToString() -> String {
        let regex = try! NSRegularExpression(pattern: "(0x)?([0-9A-Fa-f]{2})", options: .caseInsensitive)
        let textNS = self as NSString
        let matchesArray = regex.matches(in: textNS as String, options: [], range: NSMakeRange(0, textNS.length))
        let characters = matchesArray.map {
            Character(UnicodeScalar(UInt32(textNS.substring(with: $0.range(at: 2)), radix: 16)!)!)
        }
        return String(characters)
    }
}
