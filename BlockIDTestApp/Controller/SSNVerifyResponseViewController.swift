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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtView.text = markedJSONpayload
        // Do any additional setup after loading the view.
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
        mailComposeVC.setToRecipients(["ssn-crowd-test@1kosmos.com"])
        mailComposeVC.setSubject("Masked JSON Response")
        
        if let markedJSONData = markedJSONpayload, let fileData = NSData(contentsOfFile: markedJSONData)
        {
            mailComposeVC.addAttachmentData(fileData as Data, mimeType: "application/pdf", fileName: "MarkedJSONResponse.pdf")
        }
        mailComposeVC.setMessageBody("Masked JSON Response", isHTML: false)
        return mailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
