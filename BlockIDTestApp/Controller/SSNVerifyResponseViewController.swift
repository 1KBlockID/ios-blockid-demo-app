//
//  SSNVerifyResponseViewController.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 21/01/22.
//

import UIKit
import MessageUI

class SSNVerifyResponseViewController: UIViewController {

    // MARK: - IBOutlets -
    @IBOutlet weak var txtView: UITextView!
    
    var markedJSONpayload: String? = ""
    // MARK: - Private Properties -
    private var recipients: [String] {
        return ["ssn-crowd-test@1kosmos.com"]
    }
    private var messageSubject: String {
        return "Masked JSON Response"
    }
    
    // MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        txtView.text = markedJSONpayload
    }
    
    // MARK: - IBActions -
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func doShare(_ sender: UIButton) {
        if let _ = markedJSONpayload {
            let mailComposeViewController = configureMailComposer()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            }else{
                print("Can't send email")
            }
        }
    }
}

// MARK: - Extension -
extension SSNVerifyResponseViewController: MFMailComposeViewControllerDelegate {
    
    private func configureMailComposer() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(recipients)
        mailComposeVC.setSubject(messageSubject)
        mailComposeVC.addAttachmentData(Data(txtView.text.utf8), mimeType: "application/json", fileName: "Masked_Response.json")
        mailComposeVC.setMessageBody(messageSubject, isHTML: false)
        return mailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
