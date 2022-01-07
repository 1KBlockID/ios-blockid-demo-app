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
    @IBOutlet weak var txtFieldStreet: UITextField!
    @IBOutlet weak var txtFieldZipCode: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPhoneNo: UITextField!
    @IBOutlet weak var txtFieldState: UITextField!
    @IBOutlet weak var txtFieldCity: UITextField!
    @IBOutlet weak var btnUserConsent: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    
    // MARK: - Private Properties -
    private var ssnPayload: [String: Any] {
        var ssnDict: [String: Any] = [ "type": RegisterDocType.SSN.rawValue,
                                       "documentType": RegisterDocType.SSN.rawValue.uppercased(),
                                       "category": RegisterDocCategory.Misc_Document.rawValue,
                                       "userConsent": btnContinue.isSelected ]
        
        if let ssnText = txtFieldSSN.text, !ssnText.trim().isEmpty {
            ssnDict["id"] = ssnText
            ssnDict["documentId"] = ssnText
            ssnDict["ssn"] = ssnText
        }
        if let firstName = txtFieldFirstName.text, !firstName.isEmpty {
            ssnDict["firstName"] = firstName
        }
        if let middleName = txtFieldMiddleName.text, !middleName.isEmpty {
            ssnDict["middleName"] = middleName
        }
        if let lastName = txtFieldLastName.text, !lastName.isEmpty {
            ssnDict["lastName"] = lastName
        }
        if let dob = txtFieldDob.text, !dob.isEmpty {
            ssnDict["dob"] = dob
        }
        if let street = txtFieldStreet.text, !street.isEmpty {
            ssnDict["street"] = street
        }
        if let city = txtFieldCity.text, !city.isEmpty {
            ssnDict["city"] = city
        }
        if let state = txtFieldState.text, !state.isEmpty {
            ssnDict["state"] = state
        }
        if let zipCode = txtFieldZipCode.text, !zipCode.isEmpty {
            ssnDict["zipCode"] = zipCode
        }
        if let country = txtFieldCountry.text, !country.isEmpty {
            ssnDict["country"] = country
        }
        if let emailAddress = txtFieldEmail.text, !emailAddress.isEmpty {
            ssnDict["email"] = emailAddress
        }
        if let phoneNo = txtFieldPhoneNo.text, !phoneNo.isEmpty {
            ssnDict["phone"] = phoneNo
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
        txtFieldStreet.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
        
        if txtFieldSSN.text!.trim().isEmpty {
          return "SSN can not be empty"
        } else if !txtFieldSSN.text!.isValid(type: .SSN) {
            return "Invalid SSN"
        } else if txtFieldFirstName.text!.trim().isEmpty {
            return "First Name can not be empty"
        } else if !txtFieldFirstName.text!.isValid(type: .firstName) {
            return "Invalid First Name"
        } else if txtFieldLastName.text!.trim().isEmpty {
            return "Last Name can not be empty"
        } else if !txtFieldLastName.text!.isValid(type: .lastName) {
            return "Invalid Last Name"
        } else if txtFieldDob.text!.trim().isEmpty {
            return "Date of birth can not be empty"
        } else if !txtFieldDob.text!.isValid(type: .DOB) {
            return "Invalid Date of Birth"
        } else if txtFieldZipCode.text!.trim().isEmpty {
            return "Zip Code can not be empty"
        } else if !txtFieldZipCode.text!.isValid(type: .zipCode) {
            return "Invalid Zip code"
        } else if txtFieldCity.text!.trim().isEmpty {
            return "City can not be empty"
        } else if txtFieldState.text!.trim().isEmpty {
            return "State can not be empty"
        } else if txtFieldCountry.text!.trim().isEmpty {
            return "Country can not be empty"
        }
        
        return nil
    }
    
    private func verifySSN() {
        
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.verifyDocument(dvcID: AppConsant.dvcID, dic: ssnPayload)
        { status, dataDic, errorResponse in
            self.view.hideToastActivity()
            var title: String = ""
            var message: String = ""
            if status {
                if let dataDict = dataDic,
                    let certifications = dataDict["certifications"] as? [[String: Any]] {
                    if certifications.filter({ $0["verified"] as? Bool == false }).count > 1 {
                        UserDefaults.standard.set(false, forKey: "isSSNVerified")
                        title = "Error"
                        message = "The information you provided does not match the records. Please try again."
                    }
                } else {
                    UserDefaults.standard.set(true, forKey: "isSSNVerified")
                    title = "Success"
                    message = "Your Social Security Number has been verified."
                }
            } else {
                title = "Error"
                message = "There is some error in the request data"
                UserDefaults.standard.set(false, forKey: "isSSNVerified")
            }
            
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: {_ in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true)
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
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if textField == txtFieldSSN {
                let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
                if newString.count > 9 { //restrict input upto 9 characters
                    return false
                }
            }
            return true
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
