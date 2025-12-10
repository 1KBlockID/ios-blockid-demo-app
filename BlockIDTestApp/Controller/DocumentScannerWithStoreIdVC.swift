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
    private var storeId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblHeader?.text = documentTitle?.rawValue
        self.setButtonsTitle()
        
        addDoneButtonOnKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        btnVerifyDoc?.titleLabel?.textAlignment = .center
        btnVerifyDocWithSId?.titleLabel?.textAlignment = .center
    }
    
    
    func addDoneButtonOnKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: .done,
                                         target: self,
                                         action: #selector(doneButtonTapped))
        
        toolbar.items = [flexSpace, doneButton]
        
        self.txtViewUID?.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
        self.txtViewUID?.resignFirstResponder()
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
            self.showDLView(storeId: self.storeId)
            break
        case .Passport1, .Passport2:
            showPassportView(storeId: self.storeId)
            break
        case .NationalID:
            showNationalIDView(storeId: self.storeId)
            break
        default:
            break
        }
        
    }
    
    func setButtonsTitle() {
        var documentName = ""
        switch documentTitle {
        case .DriverLicense:
            documentName = "DL"
            break
        case .Passport1, .Passport2:
            documentName = "Passport"
            break
        case .NationalID:
            documentName = "National ID"
            break
        default:
            break
        }
        self.btnVerifyDoc?.setTitle("Start \(documentName) Verification", for: .normal)
        self.btnVerifyDocWithSId?.setTitle("Start \(documentName) Verification with UID", for: .normal)
    }
}

// MARK: - UITextViewDelegate -
extension DocumentScannerWithStoreIdVC: UITextViewDelegate {
   
    func textViewDidChange(_ textView: UITextView) {
        // Handle placeholder
        lblPlaceholder?.isHidden = !textView.text.isEmpty
       
        let trimmedStoreId = textView.text.trim()
        // Enable button once valid uid is entered
        self.btnVerifyDocWithSId?.isEnabled = !trimmedStoreId.isEmpty && trimmedStoreId.count <= kMAXUIDLENGTH
        
        self.storeId = trimmedStoreId.isEmpty ? nil : trimmedStoreId
    }
}
