//
//  SSNViewController.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 06/01/22.
//

import UIKit
import BlockIDSDK
import Toast_Swift

class SSNViewController: UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var txtFieldSSN: UITextField!
    @IBOutlet weak var txtFieldFirstName: UITextField!
    @IBOutlet weak var txtFieldMiddleName: UITextField!
    @IBOutlet weak var txtFieldLastName: UITextField!
    @IBOutlet weak var txtFieldDob: UITextField!
    @IBOutlet weak var txtFieldCountry: UITextField!
    @IBOutlet weak var txtFieldAddress: UITextField!
    @IBOutlet weak var txtFieldZipCode: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPhoneNo: UITextField!
    @IBOutlet weak var txtFieldState: UITextField!
    @IBOutlet weak var txtFieldCity: UITextField!
    @IBOutlet weak var btnUserConsent: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    
    // MARK: - Private Properties -
    private var ssnPayload: [String: Any] {
        var ssnDict: [String: Any] = [ "id": txtFieldSSN.text ?? "",
                                       "type": RegisterDocType.SSN.rawValue,
                                       "documentId": txtFieldSSN.text ?? "",
                                       "documentType": RegisterDocType.SSN.rawValue.uppercased(),
                                       "category": RegisterDocCategory.Misc_Document.rawValue,
                                       "userConsent": btnContinue.isSelected,
                                       "ssn": txtFieldSSN.text ?? "",
                                       "firstName": txtFieldFirstName.text ?? "",
                                       "lastName": txtFieldLastName.text ?? "",
                                       "dob": dateYYYmmDD ?? "",
                                       "street": txtFieldAddress.text ?? "",
                                       "city": txtFieldCity.text ?? "",
                                       "state": txtFieldState.text ?? "",
                                       "zipCode": txtFieldZipCode.text ?? "",
                                       "country": txtFieldCountry.text ?? "",
                                       "email": txtFieldEmail.text ?? "",
                                       "phone": txtFieldPhoneNo.text ?? "" ]
        
        if !txtFieldMiddleName.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ssnDict["middleName"] = txtFieldMiddleName.text
        }
        return ssnDict
    }
    
    private var dateYYYmmDD: String?
    
    // MARK: - View LifeCycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - IBOutlets Actions -
    @IBAction func doContinue(_ sender: UIButton) {
        guard let error = isValidInput() else {
            verifySSN()
            return
        }
        self.showAlertView(title: "Alert", message: error)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doUserConsent(_ sender: UIButton) {
       btnUserConsent.isSelected = !btnUserConsent.isSelected
    }
}


// MARK: - Extension -
extension SSNViewController {
    
    private func setupObservers() {
        txtFieldCity.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldSSN.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldDob.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldAddress.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldZipCode.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldState.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldCountry.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldLastName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldFirstName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        btnContinue.isUserInteractionEnabled = btnUserConsent.isSelected
        btnContinue.isUserInteractionEnabled = !textField.text!.isEmpty
        btnContinue.backgroundColor = textField.text!.isEmpty ? .darkGray : .black
    }
    
    // TextField Validations
    private func isValidInput() -> String? {
        
        if txtFieldSSN.text!.isEmpty {
          return "SSN can not be empty"
        } else if !txtFieldFirstName.text!.isValid(type: .SSN) {
            return "Invalid SSN"
        } else if txtFieldFirstName.text!.isEmpty {
            return "First Name can not be empty"
        } else if !txtFieldFirstName.text!.isValid(type: .firstName) {
            return "Invalid First Name"
        } else if txtFieldLastName.text!.isEmpty {
            return "Last Name can not be empty"
        } else if !txtFieldLastName.text!.isValid(type: .lastName) {
            return "Invalid Last Name"
        } else if txtFieldDob.text!.isEmpty {
            return "Date of birth can not be empty"
        } else if !txtFieldDob.text!.isValid(type: .DOB) {
            return "Invalid Date of Birth"
        } else if txtFieldZipCode.text!.isEmpty {
            return "Zip Code can not be empty"
        } else if !txtFieldZipCode.text!.isValid(type: .zipCode) {
            return "Invalid Zip code"
        } else if txtFieldCity.text!.isEmpty {
            return "City can not be empty"
        } else if txtFieldState.text!.isEmpty {
            return "State can not be empty"
        } else if txtFieldCountry.text!.isEmpty {
            return "Country can not be empty"
        }
        
        return nil
    }
    
    private func verifySSN() {
        
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.verifyDocument(dvcID: AppConsant.dvcID, dic: ssnPayload) { status, dataDic, errorResponse in
            self.view.hideToastActivity()
            if status {
                if let dataDict = dataDic, let certifications = dataDict["certifications"] as? [[String: Any]] {
                    if certifications.filter({ $0["verified"] as? Bool == false }).count > 1 {
                        self.view.makeToast("The information you provided does not match the records. Please try again.", duration: 3.0, position: .center, title: "Error", completion: {_ in
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                } else {
                    self.view.makeToast("Your Social Security Number has been verified.", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            } else {
                self.view.makeToast(errorResponse?.message ?? "Verification Failed", duration: 3.0, position: .center, title: "Error", completion: {_ in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
}
    
    // MARK: - UITextFieldDelegate -
    extension SSNViewController: UITextFieldDelegate {
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            if textField == txtFieldDob {
                let picker = UIDatePicker()
                picker.datePickerMode = .date
                picker.addTarget(self, action: #selector(updateDateField(sender:)), for: .valueChanged)
                // If the date field has focus, display a date picker instead of keyboard.
                // Set the text to the date currently displayed by the picker.
                textField.inputView = picker
                textField.text = formatDateForDisplay(date: picker.date)
            }
        }
        
        @objc func updateDateField(sender: UIDatePicker) {
            txtFieldDob?.text = formatDateForDisplay(date: sender.date)
        }
        
        
        // Formats the date chosen with the date picker.
        fileprivate func formatDateForDisplay(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "yyyy/mm/dd"
            dateYYYmmDD = formatter2.string(from: date)
            
            return formatter.string(from: date)
        }
    }
