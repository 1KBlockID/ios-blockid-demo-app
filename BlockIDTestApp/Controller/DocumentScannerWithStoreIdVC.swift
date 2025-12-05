//
//  DocumentScannerWithStoreIdVC.swift
//  1Kosmos Demo
//
//  Created by Prasanna Gupta on 04/12/25.
//

import UIKit
import BlockID

class DocumentScannerWithStoreIdVC: UIViewController {
    @IBOutlet private weak var btnVerifyDoc: UIButton?
    @IBOutlet private weak var btnVerifyDocWithSId: UIButton?
    @IBOutlet private weak var lblHeader: UILabel?
    @IBOutlet private weak var lblPlaceholder: UILabel?
    @IBOutlet private weak var txtViewUID: UITextView?

    var documentTitle: Enrollments?
    private let kMAXUIDLENGTH = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblHeader?.text = documentTitle?.rawValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        btnVerifyDoc?.titleLabel?.textAlignment = .center
        btnVerifyDocWithSId?.titleLabel?.textAlignment = .center
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnVerifyDocumentClicked(_ sender: UIButton) {
       
        switch documentTitle {
        case .DriverLicense:
            showDLView()
            break
        case .Passport1, .Passport2:
            showPassportView()
            break
        case .NationalID:
            showNationalIDView()
            break
        default:
            break
        }
    }
    
    @IBAction func btnVerifyDocumentWithStoreIdClicked(_ sender: UIButton) {
        
        switch documentTitle {
        case .DriverLicense:
            showDLView()
            break
        case .Passport1, .Passport2:
            showPassportView()
            break
        case .NationalID:
            showNationalIDView()
            break
        default:
            break
        }
    }
}

// MARK: - UITextViewDelegate -
extension DocumentScannerWithStoreIdVC: UITextViewDelegate {
   
    func textViewDidChange(_ textView: UITextView) {
        lblPlaceholder?.isHidden = !textView.text.isEmpty
       
        // Enable button once valid uid is entered
        self.btnVerifyDocWithSId?.isEnabled = !textView.text.trim().isEmpty
    }
}
