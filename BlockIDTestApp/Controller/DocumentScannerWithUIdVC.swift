//
//  DocumentScannerWithUIdVC.swift
//  1Kosmos Demo
//
//  Created by Prasanna Gupta on 04/12/25.
//

import UIKit
import BlockID

class DocumentScannerWithUIdVC: UIViewController {
    @IBOutlet private weak var btnVerifyDoc: UIButton?
    @IBOutlet private weak var btnVerifyDocWithSId: UIButton?
    @IBOutlet private weak var lblHeader: UILabel?
    @IBOutlet private weak var lblPlaceholder: UILabel?
    @IBOutlet private weak var txtViewUID: UITextView?
    
    var documentTitle: Enrollments?
    private let maxUIDLength = 100
    private var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblHeader?.text = documentTitle?.rawValue
        self.setButtonsTitle()
        
        addDoneButtonOnKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txtViewUID?.textContainerInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        
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
    
    @IBAction func btnVerifyDocumentWithUIdClicked(_ sender: UIButton) {
        
        switch documentTitle {
        case .DriverLicense:
            self.showDLView(UId: self.uid)
            break
        case .Passport1, .Passport2:
            showPassportView(UId: self.uid)
            break
        case .NationalID:
            showNationalIDView(UId: self.uid)
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
extension DocumentScannerWithUIdVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // Handle placeholder
        lblPlaceholder?.isHidden = !textView.text.isEmpty
        
        let trimmedUid = textView.text.trim()
        // Enable button once valid uid is entered
        self.btnVerifyDocWithSId?.isEnabled = !trimmedUid.isEmpty
        
        self.uid = trimmedUid.isEmpty ? nil : trimmedUid
    }
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        // Current text
        let currentText = textView.text ?? ""
        
        // Detect deletion
        let isDeleting = (text.isEmpty && range.length > 0)
        if isDeleting {
            return true   // Always allow delete/backspace
        }
        // Proposed new text
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // Limit to 100 chars
        let trimmedUid = textView.text.trim()
        return trimmedUid.count < maxUIDLength
    }
}
