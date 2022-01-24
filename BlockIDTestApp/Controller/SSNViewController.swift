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
    // to store the current active textfield
    private var activeTextField : UITextField? = nil
    private var maskedData = "XXXXXX"
    private var ssnPayload: [String: Any] {
        var ssnDict: [String: Any] = [ "type": RegisterDocType.SSN.rawValue,
                                       "category": RegisterDocCategory.Misc_Document.rawValue,
                                       "userConsent": btnContinue.isSelected ]
        
        if let ssnText = txtFieldSSN.text, !ssnText.trim().isEmpty {
            ssnDict["id"] = ssnText
            ssnDict["ssn"] = ssnText
        }
        if let firstName = txtFieldFirstName.text, !firstName.isEmpty {
            ssnDict["firstName"] = firstName.condenseWhitespace()
        }
        if let middleName = txtFieldMiddleName.text, !middleName.isEmpty {
            ssnDict["middleName"] = middleName.condenseWhitespace()
        }
        if let lastName = txtFieldLastName.text, !lastName.isEmpty {
            ssnDict["lastName"] = lastName.condenseWhitespace()
        }
        if let dob = self.dateYYYmmDD, !dob.isEmpty {
            ssnDict["dob"] = dob
        }
        if let street = txtFieldStreet.text, !street.isEmpty {
            ssnDict["street"] = street.condenseWhitespace()
        }
        if let city = txtFieldCity.text, !city.isEmpty {
            ssnDict["city"] = city.condenseWhitespace()
        }
        if let state = txtFieldState.text, !state.isEmpty {
            ssnDict["state"] = state.condenseWhitespace()
        }
        if let zipCode = txtFieldZipCode.text, !zipCode.isEmpty {
            ssnDict["zipCode"] = zipCode
        }
        if let country = txtFieldCountry.text, !country.isEmpty {
            ssnDict["country"] = country.condenseWhitespace()
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
    private var isAllFieldsValid: Bool = false
    
    // MARK: - View LifeCycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        btnContinue.isEnabled = false
        self.btnContinue.backgroundColor = .darkGray
        self.btnContinue.layer.cornerRadius = self.btnContinue.frame.height/2
        setupObservers()
        setupDataSource()
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
        continueBtnStateConfig()
    }
}


// MARK: - Extension -
extension SSNViewController {
    
    private func setupObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        [txtFieldCity, txtFieldSSN, txtFieldDob,
         txtFieldStreet, txtFieldZipCode, txtFieldState,
         txtFieldCountry, txtFieldLastName, txtFieldFirstName].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
    }
    
    private func setupDataSource() {
        if BlockIDSDK.sharedInstance.isDLEnrolled() {
            let strDocuments = BIDDocumentProvider.shared.getUserDocument(id: "",
                                                                          type: RegisterDocType.DL.rawValue,
                                                                          category: RegisterDocCategory.Identity_Document.rawValue) ?? ""
            guard let arrDocuments = CommonFunctions.convertJSONStringToJSONObject(strDocuments) as? [[String : Any]], arrDocuments.count > 0 else {
                return
            }
            txtFieldFirstName.text = arrDocuments[0]["firstName"] as? String
            txtFieldLastName.text = arrDocuments[0]["lastName"] as? String
            txtFieldDob.text = arrDocuments[0]["dob"] as? String
            txtFieldStreet.text = arrDocuments[0]["street"] as? String
            txtFieldCity.text = arrDocuments[0]["city"] as? String
            txtFieldState.text = arrDocuments[0]["state"] as? String
            txtFieldZipCode.text = arrDocuments[0]["zipCode"] as? String
            txtFieldCountry.text = arrDocuments[0]["country"] as? String
            
        }
    }
    
    @objc func editingChanged(textField: UITextField) {
        
        guard
            let firstName = txtFieldFirstName.text, !firstName.isEmpty,
            let lastName = txtFieldLastName.text, !lastName.isEmpty,
            let state = txtFieldState.text, !state.isEmpty,
            let zipCode = txtFieldZipCode.text, !zipCode.isEmpty,
            let city = txtFieldCity.text, !city.isEmpty,
            let ssn = txtFieldSSN.text, !ssn.isEmpty,
            let dob = txtFieldDob.text, !dob.isEmpty,
            let country = txtFieldCountry.text, !country.isEmpty,
            let street = txtFieldStreet.text, !street.isEmpty
        else
        {
            isAllFieldsValid = false
            self.btnContinue.isEnabled = false
            self.btnContinue.backgroundColor = .darkGray
            return
        }
        // enable continue if all conditions are met
        isAllFieldsValid = true
        if btnUserConsent.isSelected {
            continueBtnStateConfig()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
        var shouldMoveViewUp = false
        // if active text field is not nil
        if let activeTextField = activeTextField {
            
            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
            let topOfKeyboard = self.view.frame.height - keyboardSize.height
            // if the bottom of Textfield is below the top of keyboard, move up
            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
        }
        if(shouldMoveViewUp) {
            self.view.frame.origin.y = 0 - keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
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
        } else if txtFieldStreet.text!.trim().isEmpty {
            return "Street can not be empty"
        } else if txtFieldZipCode.text!.trim().isEmpty {
            return "Zip Code can not be empty"
        } else if txtFieldCity.text!.trim().isEmpty {
            return "City can not be empty"
        } else if txtFieldState.text!.trim().isEmpty {
            return "State can not be empty"
        } else if !txtFieldZipCode.text!.isValid(type: .zipCode) {
            return "Invalid Zip code"
        } else if txtFieldCountry.text!.trim().isEmpty {
            return "Country can not be empty"
        } else if !btnUserConsent.isSelected {
            return "Consent is not given"
        }
        
        return nil
    }
    
    private func continueBtnStateConfig() {
        if  isAllFieldsValid && btnUserConsent.isSelected {
            self.btnContinue.isEnabled = true
            self.btnContinue.backgroundColor = .black
        } else {
            self.btnContinue.isEnabled = false
            self.btnContinue.backgroundColor = .darkGray
        }
    }
    
    private func verifySSN() {
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.verifyDocument(dvcID: AppConsant.dvcID, dic: ssnPayload)
        { status, dataDic, errorResponse in
            self.view.hideToastActivity()
            var title: String = ""
            var message: String = ""
            var alertTag: Int = 0
            if status {
                if let dataDict = dataDic,
                    let certifications = dataDict["certifications"] as? [[String: Any]] {
                    
                    if certifications.filter({ $0["status"] as? Int == 400 }).count >= 1 {
                        title = "Error"
                        message = "There is some error in the request data"
                        alertTag = 1001
                    } else {
                        if certifications.filter({ $0["verified"] as? Bool == false }).count >= 1 {
                            title = "Error"
                            message = "The information you provided does not match the records. Please try again."
                            alertTag = 1001
                        } else {
                            title = "Success"
                            message = "Your Social Security Number has been verified."
                            alertTag = 1002
                        }
                    }
                }
            } else {
                title = "Error"
                alertTag = 1001
                message = "There is some error in the request data"
            }
            
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            if alertTag == 1002 {
                alert.addAction(UIAlertAction(title: "OK",
                                              style: .default,
                                              handler: {_ in
                        self.navigationController?.popViewController(animated: true)
                }))
            } else if alertTag == 1001 {
                alert.addAction(UIAlertAction(title: "Retry",
                                              style: .default,
                                              handler: nil))
                alert.addAction(UIAlertAction(title: "Details", style: .default, handler: { action in
                    // navigate to next screen
                    if let dataDic = dataDic {
                        if let payload = self.handleFailedSSNResponse(payload: dataDic) {
                            
                            if let theJSONData = try? JSONSerialization.data(
                                withJSONObject: payload,
                                options: []) {
                                let theJSONText = String(data: theJSONData,
                                                           encoding: .ascii)
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                if let ssnResponseVc = storyBoard.instantiateViewController(withIdentifier: "SSNVerifyResponseViewController") as? SSNVerifyResponseViewController {
                                    ssnResponseVc.markedJSONpayload = theJSONText
                                    self.navigationController?.pushViewController(ssnResponseVc, animated: true)
                                }
                            }
                        }
                    }
                }))
            }
            self.present(alert, animated: true)
        }
    }
    
    private func handleFailedSSNResponse(payload: [String: Any]) -> [String: Any]? {
        
        var dataDic: [String: Any]?
        if let certifications = payload["certifications"] as? [[String: Any]] {
            for certificate in certifications {
                if let metaData = certificate["metadata"] as? [String: Any] {
                    if let verfiedPeople = metaData["verifiedPeople"] as? [[String: Any]] {
                        for var people in verfiedPeople {
                            
                            if var frstName = people["firstName"] as? [String: Any], let _ = frstName["value"] {
                                frstName.updateValue(maskedData, forKey: "value")
                            }
                            
                            if var middleName = people["middleName"] as? [String: Any], let _ = middleName["value"] {
                                middleName.updateValue(maskedData, forKey: "value")
                            }
                            
                            if var lastName = people["lastName"] as? [String: Any], let _ = lastName["value"] {
                                lastName.updateValue(maskedData, forKey: "value")
                            }
                            
                            if var ssn = people["ssn"] as? [String: Any], let _ = ssn["value"] {
                                ssn.updateValue(maskedData, forKey: "value")
                            }
                            
                            if let dob = people["dateOfBirth"] as? [String: Any] {
                                if var month = dob["month"] as? [String: Any], let _ = month["value"] {
                                    month.updateValue(maskedData, forKey: "value")
                                }
                                if var day = dob["day"] as? [String: Any], let _ = day["value"] {
                                    day.updateValue(maskedData, forKey: "value")
                                }
                                if var year = dob["year"] as? [String: Any], let _ = year["value"] {
                                    year.updateValue(maskedData, forKey: "value")
                                }
                            }
                            
                            if var age = people["age"] as? [String: Any], let _ = age["value"] {
                                age.updateValue(maskedData, forKey: "value")
                            }
                            
                            if let addresses =  people["addresses"] as? [[String: Any]] {
                                for var address in addresses {
                                    address["value"] = maskedData
                                }
                            }
                            if let emails =  people["emails"] as? [[String: Any]] {
                                for var email in emails {
                                    email["value"] = maskedData
                                }
                            }
                            if let phones =  people["phones"] as? [[String: Any]] {
                                for var phone in phones {
                                    phone["value"] = maskedData
                                }
                            }
                            
                            
                            people["indicators"] = maskedData
                        }
                    }
                }
            }
        }
        dataDic = payload
        return dataDic
    }
}
    
    // MARK: - UITextFieldDelegate -
    extension SSNViewController: UITextFieldDelegate {
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.activeTextField = textField
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
            
            if textField.text?.count == 0 && string == " " {
                return false
            }
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) {
                    return true
                }
            }
            let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
            if textField == txtFieldSSN {
                return newString.count <= 9
            } else if textField == txtFieldZipCode {
                return newString.count <= 5
            }
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            self.activeTextField = nil
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
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
            formatter2.dateFormat = "yyyy/MM/dd"
            dateYYYmmDD = formatter2.string(from: date)
            return formatter.string(from: date)
        }
    }
