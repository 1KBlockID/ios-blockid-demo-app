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
    @IBOutlet weak var txtFieldDob: UITextField!
    @IBOutlet weak var btnUserConsent: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var userConsetTxtVw: UITextView!
    
    // MARK: - Private Properties -
    // to store the current active textfield
    private var activeTextField : UITextField? = nil
    private var maskedData = "XXXXXX"
    private let hyperLinkText: String = "Fair Credit Reporting Act"
    private let hyperLinkURL: String = "https://www.ftc.gov/legal-library/browse/statutes/fair-credit-reporting-act"
    private var verifiedPerson = VerifiedPerson()
    private var certification = [String: Any]()
    private let expectedDateFormat: String = "yyyyMMdd"
    private let displayDateFormat: String = "MMM, dd yyyy"
    private var isAllFieldsValid: Bool = false
    
    // MARK: - View LifeCycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        btnContinue.isEnabled = false
        self.btnContinue.backgroundColor = .darkGray
        self.btnContinue.layer.cornerRadius = self.btnContinue.frame.height/2
        displayAsHyperLink()
        setupObservers()
        addDoneButtonOnKeyboard()
        setupDataSource()
    }
    
    // Manage hyper link clicking...
    private func displayAsHyperLink() {
        let attributedString = NSMutableAttributedString(string: userConsetTxtVw.text)
        if let mutatedString = attributedString.createHyperLink(textToFind: hyperLinkText,
                                                                linkURL: hyperLinkURL) {
            userConsetTxtVw.attributedText = mutatedString
        }
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
        [txtFieldSSN].forEach({ $0.addTarget(self, action: #selector(editingChanged),
                                             for: .editingChanged) })
    }
    
    private func setupDataSource() {
        
        let isDLEnrolled = BIDDocumentProvider.shared.getDocument(id: nil,
                                                                  type: RegisterDocType.DL.rawValue, category: nil) != nil
        
        if isDLEnrolled {
            let strDocuments = BIDDocumentProvider.shared.getUserDocument(id: "",
                                                                          type: RegisterDocType.DL.rawValue,
                                                                          category: RegisterDocCategory.Identity_Document.rawValue) ?? ""
            guard let arrDocuments = CommonFunctions.convertJSONStringToJSONObject(strDocuments) as? [[String : Any]], arrDocuments.count > 0 else {
                return
            }
            txtFieldDob.text = self.getFormattedDate(date: arrDocuments[0]["dob"] as? String ?? "",
                                                     fromFormat: expectedDateFormat,
                                                     toFormat: displayDateFormat) ?? ""

        }
    }
    
    private func verifySSN() {
        var identityDocument = [String: Any]()
        
        let isDLEnrolled = BIDDocumentProvider.shared.getDocument(id: nil,
                                                                  type: RegisterDocType.DL.rawValue, category: nil) != nil
        
        let isPPTEnrolled = BIDDocumentProvider.shared.getDocument(id: nil,
                                                                  type: RegisterDocType.PPT.rawValue, category: nil) != nil
        
        if isDLEnrolled {
            let strDocuments = BIDDocumentProvider.shared.getUserDocument(id: "",
                                                                          type: RegisterDocType.DL.rawValue,
                                                                          category: RegisterDocCategory.Identity_Document.rawValue) ?? ""
            guard let documents = CommonFunctions.convertJSONStringToJSONObject(strDocuments) as? [[String: Any]], !documents.isEmpty else {
                return
            }
            identityDocument = documents.first ?? [:]
        } else if isPPTEnrolled {
            let strDocuments = BIDDocumentProvider.shared.getUserDocument(id: "",
                                                                          type: RegisterDocType.PPT.rawValue,
                                                                          category: RegisterDocCategory.Identity_Document.rawValue) ?? ""
            guard let documents = CommonFunctions.convertJSONStringToJSONObject(strDocuments) as? [[String: Any]], !documents.isEmpty else {
                return
            }
            identityDocument = documents.first ?? [:]
        }
        // Verify SSN
        verifySSN(identityDocument)
    }
    
    @objc func editingChanged(textField: UITextField) {
        
        guard
            let ssn = txtFieldSSN.text, !ssn.isEmpty,
            let dob = txtFieldDob.text, !dob.isEmpty
        else
        {
            self.isAllFieldsValid = false
            self.btnContinue.isEnabled = false
            self.btnContinue.backgroundColor = .darkGray
            return
        }
        // enable continue if all conditions are met
        self.isAllFieldsValid = true
        if btnUserConsent.isSelected {
            continueBtnStateConfig()
        }
    }
    
    // Add Done button on UITextfields of type NUMPAD
    private func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0.0,
                                                             y: 0.0,
                                                             width: UIScreen.main.bounds.width,
                                                             height: 50.0))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done",
                                                    style: .done, target: self,
                                                    action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        txtFieldSSN.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        txtFieldSSN.resignFirstResponder()
    }
    
    // TextField Validations
    private func isValidInput() -> String? {
        if txtFieldSSN.text!.trim().isEmpty {
          return "SSN can not be empty"
        } else if !txtFieldSSN.text!.isValid(type: .SSN) {
            return "Invalid SSN"
        } else if txtFieldDob.text!.trim().isEmpty {
            return "Date of birth can not be empty"
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
    
    // Formatting date from expectedDate to displayDate..
    private func getFormattedDate(date: String, fromFormat: String, toFormat: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        guard let paramDate = dateFormatter.date(from: date) else { return  nil}
        let resultDateFormatter = DateFormatter()
        resultDateFormatter.dateFormat = toFormat
        let strDate = resultDateFormatter.string(from: paramDate)
        return strDate
    }
    
    private func getVerifySSNPayload(_ docData: [String: Any]) -> [String: Any] {
        let ssn = self.txtFieldSSN.text ?? ""
        var dictPayload = [String: Any]()
        dictPayload["type"] = "ssn"
        dictPayload["id"] = ssn.sha256()
        
        // set date of birth
        let dateOfBirth = (docData["dob"] as? String) ?? ""
        dictPayload["dob"] = getFormattedDateOfBirth(dateOfBirth: dateOfBirth)
       
        dictPayload["ssn"] = ssn
        return dictPayload
    }
    
    private func getFormattedDateOfBirth(dateOfBirth: String) -> String {
        // set date of birth
        let reqDateFormat = "yyyyMMdd"
        if dateOfBirth.isValidDate(dateFormat: reqDateFormat) {
            // use existing date
            return dateOfBirth
        } else {
            // convert date format
            let date = dateOfBirth.toDateFormat(with: "MMddyyyy")
            return date?.toStringDate(with: reqDateFormat) ?? dateOfBirth
        }
    }
    
    private func verifySSN(_ dictDocumentObj: [String: Any]) {
        self.view.makeToastActivity(.center)
        
        let dictPayload = getVerifySSNPayload(dictDocumentObj)
        BlockIDSDK.sharedInstance.verifyDocument(dic: dictPayload,
                                                 verifications: ["ssn_verify"])
        { [weak self] (status, dataDic, errorResponse) in
            guard let weakSelf = self else {return}
            weakSelf.view.hideToastActivity()
            var title: String = ""
            var message: String = ""
            var alertTag: Int = 0
            if status {
                if let dataDict = dataDic,
                    let certifications = dataDict["certifications"] as? [[String: Any]] {
                    weakSelf.certification = certifications[0]
                    
                    // Get certification verified
                    let verified = weakSelf.certification["verified"] as? Bool
                    
                    // Get verifiedPeople array
                    let metadata = weakSelf.certification["metadata"] as? [String: Any] ?? [:]
                    let arrVerifiedPeople = metadata["verifiedPeople"] as? [[String: Any]] ?? []
                    if let isVerified = verified, isVerified == true && arrVerifiedPeople.count == 1 {
                            title = "Success"
                            message = "Do you want to register your verified SSN?"
                            //"Your Social Security Number has been verified."
                            alertTag = 1002
                            
                            if let isVerified = verified, isVerified == true && arrVerifiedPeople.count == 1 {
                                // Create model class for verified person
                                if let verifiedPersonObj = self?.parseJsonWith(dictVerifiedPerson: arrVerifiedPeople[0]) {
                                    // get details from response
                                    let responseFirstName = verifiedPersonObj.firstName?.lowercased()
                                    let responseLastName = verifiedPersonObj.lastName?.lowercased()
                                    // get details from document
                                    let docFirstName = (dictDocumentObj["firstName"] as? String ?? "").lowercased()
                                    let docLastName = (dictDocumentObj["lastName"] as? String ?? "").lowercased()
                                    // Triangulate data after valid SSN
                                    if (responseFirstName == docFirstName && responseLastName == docLastName) ||
                                        (responseLastName == docFirstName && responseFirstName == docLastName) {
                                        // Enroll SSN
                                        weakSelf.verifiedPerson = verifiedPersonObj
                                    } else {
                                        // verification failed
                                        weakSelf.view.makeToast("There is some error in the request data", duration: 3.0, position: .center, title: "Error!", completion: {_ in
                                            weakSelf.navigationController?.popViewController(animated: true)
                                        })
                                    }
                                }
                            }
                    } else {
                        if certifications.filter({ $0["status"] as? Int == 400 }).count >= 1 ||
                            certifications.filter({ $0["verified"] as? Bool == false }).count >= 1 {
                            title = "Error"
                            message = "The information you provided does not match the records."
                            alertTag = 1001
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
                alert.addAction(UIAlertAction(title: "No",
                                              style: .default,
                                              handler: nil))
                alert.addAction(UIAlertAction(title: "Yes",
                                              style: .default,
                                              handler: {_ in
                    weakSelf.enrollSSN(weakSelf.verifiedPerson, weakSelf.certification)
                }))
            } else if alertTag == 1001 {
                alert.addAction(UIAlertAction(title: "Retry",
                                              style: .default,
                                              handler: nil))
                alert.addAction(UIAlertAction(title: "Details", style: .default,
                                              handler: { action in
                    // navigate to next screen
                    if var dataDic = dataDic {
                        if let payload = weakSelf.handleFailedSSNResponse(payload: &dataDic) {
                            
                            if let theJSONData = try? JSONSerialization.data(
                                withJSONObject: payload,
                                options: []) {
                                let theJSONText = String(data: theJSONData,
                                                           encoding: .ascii)
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",
                                                                             bundle:nil)
                                if let ssnResponseVc = storyBoard.instantiateViewController(withIdentifier: "SSNVerifyResponseViewController") as? SSNVerifyResponseViewController {
                                    ssnResponseVc.markedJSONpayload = theJSONText
                                    weakSelf.navigationController?.pushViewController(ssnResponseVc,
                                                                                      animated: true)
                                }
                            }
                        }
                    }
                }))
            }
            weakSelf.present(alert, animated: true)
        }
    }
    
    func parseJsonWith(dictVerifiedPerson: [String: Any]) -> VerifiedPerson {
        var dateOfBirth: String {
            if let dob = dictVerifiedPerson["dateOfBirth"] as? [String: Any], !dob.isEmpty {
                let year = (dob["year"] as? [String: Any])?["value"] as? String ?? "0000"
                let month = (dob["month"] as? [String: Any])?["value"] as? String ?? "0"
                let day = (dob["day"] as? [String: Any])?["value"] as? String ?? "0"
                let modifiedMonth = month.count == 1 ? ("0" + month) : month
                let modifiedDay = day.count == 1 ? ("0" + day) : day
                return year+modifiedMonth+modifiedDay
            } else {
                return ""
            }
        }
        var dateOfExpiry: String {
            if let dob = dictVerifiedPerson["dateOfBirth"] as? [String: Any], !dob.isEmpty {
                let year = (dob["year"] as? [String: Any])?["value"] as? String ?? "0000"
                let yearOfDoe = (Int(year) ?? 0) + 150
                let month = (dob["month"] as? [String: Any])?["value"] as? String ?? "0"
                let day = (dob["day"] as? [String: Any])?["value"] as? String ?? "0"
                let modifiedMonth = month.count == 1 ? ("0" + month) : month
                let modifiedDay = day.count == 1 ? ("0" + day) : day
                return String(yearOfDoe)+modifiedMonth+modifiedDay
            } else {
                return ""
            }
        }
        var verifiedPerson = VerifiedPerson()
        // First Name
        let dictFirstName = dictVerifiedPerson["firstName"] as? [String: Any] ?? [:]
        if let firstNameOfPerson = dictFirstName["value"] as? String, !firstNameOfPerson.isEmpty {
            verifiedPerson.firstName = firstNameOfPerson.condenseWhitespace()
        }
        // Middle name
        let dictMiddleName = dictVerifiedPerson["middleName"] as? [String: Any] ?? [:]
        if let middleNameOfPerson = dictMiddleName["value"] as? String, !middleNameOfPerson.isEmpty {
            verifiedPerson.middleName = middleNameOfPerson.condenseWhitespace()
        }
        // Last name
        let dictLastName = dictVerifiedPerson["lastName"] as? [String: Any] ?? [:]
        if let lastNameOfPerson = dictLastName["value"] as? String, !lastNameOfPerson.isEmpty {
            verifiedPerson.lastName = lastNameOfPerson.condenseWhitespace()
        }
        // Date of birth
        verifiedPerson.dob = dateOfBirth
        // Date of Expiry
        verifiedPerson.doe = dateOfExpiry
        // Addresses
        if let addresses = dictVerifiedPerson["addresses"] as? [[String: Any]], !addresses.isEmpty {
            var ssnAddresses: [String] = []
            for address in addresses {
                if let addressValue = address["value"] as? String, !addressValue.isEmpty {
                    ssnAddresses.append(addressValue)
                }
            }
            verifiedPerson.addresses = ssnAddresses
        }
        // Email
        if let emailAddress = dictVerifiedPerson["emails"] as? [[String: Any]], !emailAddress.isEmpty {
            for email in emailAddress {
                if let emailAddressValue = email["value"] as? String, !emailAddressValue.isEmpty {
                    verifiedPerson.email = emailAddressValue
                    break
                }
            }
        }
        // Phone
        if let phoneNumbers = dictVerifiedPerson["phones"] as? [[String: Any]], !phoneNumbers.isEmpty {
            for phone in phoneNumbers {
                if let phoneNumberValue = phone["value"] as? String, !phoneNumberValue.isEmpty {
                    verifiedPerson.phoneNumber = phoneNumberValue
                    break
                }
            }
        }
        return verifiedPerson
    }
    
    func prepareSSNPayload(verifiedPersonObj: VerifiedPerson, certification: [String: Any]) -> [String: Any] {
        var ssnData: [String: Any] = [ "type": RegisterDocType.SSN.rawValue.lowercased(),
                                       "documentType": RegisterDocType.SSN.rawValue.uppercased(),
                                       "category": RegisterDocCategory.Identity_Document.rawValue,
                                       "verifiedScan": true]
        
        // Get certifications token
        if let certificateToken = certification["token"] as? String {
            ssnData["certificate_token"] = certificateToken
        }

        // Get certifications proofed by
        if let proofedBy = certification["authority"] as? String {
            ssnData["proofedBy"] = proofedBy
        }
        
        // Get certifications proof_jwt token
        if let proofJWT = certification["proof_jwt"] as? String {
            ssnData["proof_of_verification"] = [proofJWT]
        }
        
        let ssn = txtFieldSSN.text ?? ""
        ssnData["id"] = ssn.sha256()
        ssnData["ssn"] = ssn
        ssnData["documentId"] = ssn.sha256()
        
        if let firstName = verifiedPersonObj.firstName {
            ssnData["firstName"] = firstName
        }
        
        if let middleName = verifiedPersonObj.middleName {
            ssnData["middleName"] = middleName
        }
        
        if let lastName = verifiedPersonObj.lastName {
            ssnData["lastName"] = lastName
        }
        
        if let dob = verifiedPersonObj.dob {
            ssnData["dob"] = dob
            ssnData["doi"] = dob
        }
        
        if let doe = verifiedPersonObj.doe {
            ssnData["doe"] = doe
        }
        
        if let addresses = verifiedPersonObj.addresses {
            ssnData["addresses"] = addresses
        }
        
        if let email = verifiedPersonObj.email {
            ssnData["email"] = email
        }
        
        if let phoneNumber = verifiedPersonObj.phoneNumber {
            ssnData["phoneNumber"] = phoneNumber
        }
        
        ssnData["face"] = getUserImage()
        
        if let bitMapImg = UIImage.getBitMapImage(with: UIColor.clear) {
            ssnData["image"] = CommonFunctions.convertImageToBase64String(img: bitMapImg)
        }
        return ssnData
    }
    
    // Fetch base64 UserImage
    private func getUserImage() -> String? {
        if let image = BlockIDSDK.sharedInstance.getLiveIDImage() {
            return CommonFunctions.convertImageToBase64String(img: image)
        }
        return nil
    }
    
    // Registering SSN.....
    private func enrollSSN(_ verifiedPersonObj: VerifiedPerson, _ certification: [String: Any]) {
        let ssnPayload = prepareSSNPayload(verifiedPersonObj: verifiedPersonObj,
                                           certification: certification)
        self.view.makeToastActivity(.center)
        BlockIDSDK.sharedInstance.registerDocument(obj: ssnPayload,
                                                   sigToken: nil)
        { (status, error) in
            DispatchQueue.main.async {
                // Hide loader
                self.view.hideToastActivity()
                
                if !status {
                    // FAILED
                    self.view.makeToast(error?.message,
                                        duration: 3.0,
                                        position: .center,
                                        title: "Error!",
                                        completion: {_ in
                        self.navigationController?.popViewController(animated: true)
                    })
                    return
                }
                // SUCCESS
                self.view.makeToast("SSN enrolled successfully.",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Thank you!",
                                    completion: {_ in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
    private func handleFailedSSNResponse(payload: inout [String: Any]) -> [String: Any]? {
        
        var certificates: [[String: Any]] = [[:]]
        var verifiedPeople: [[String: Any]] = [[:]]
        
        if let certifcations = payload["certifications"] as? [[String: Any]] {
            for var certificate in certifcations {
                if var metaData = certificate["metadata"] as? [String: Any] {
                    if let verfiedPeople = metaData["verifiedPeople"] as? [[String: Any]] {
                        
                        for var people in verfiedPeople {
                            
                            if var frstName = people["firstName"] as? [String: Any], let _ = frstName["value"] {
                                frstName.updateValue(maskedData, forKey: "value")
                                people["firstName"] = frstName
                            }
                            
                            if var middleName = people["middleName"] as? [String: Any], let _ = middleName["value"] {
                                middleName.updateValue(maskedData, forKey: "value")
                                people["middleName"] = middleName
                            }
                            
                            if var lastName = people["lastName"] as? [String: Any], let _ = lastName["value"] {
                                lastName.updateValue(maskedData, forKey: "value")
                                people["lastName"] = lastName
                            }
                            
                            if var ssn = people["ssn"] as? [String: Any], let _ = ssn["value"] {
                                ssn.updateValue(maskedData, forKey: "value")
                                people["ssn"] = ssn
                            }
                            
                            if var dob = people["dateOfBirth"] as? [String: Any] {
                                if var month = dob["month"] as? [String: Any], let _ = month["value"] {
                                    month.updateValue(maskedData, forKey: "value")
                                    dob["month"] = month
                                }
                                if var day = dob["day"] as? [String: Any], let _ = day["value"] {
                                    day.updateValue(maskedData, forKey: "value")
                                    dob["day"] = day
                                }
                                if var year = dob["year"] as? [String: Any], let _ = year["value"] {
                                    year.updateValue(maskedData, forKey: "value")
                                    dob["year"] = year
                                }
                                people["dateOfBirth"] = dob
                            }
                            
                            if var age = people["age"] as? [String: Any], let _ = age["value"] {
                                age.updateValue(maskedData, forKey: "value")
                                people["age"] = age
                            }
                            
                            if let addresses = people["addresses"] as? [[String: Any]] {
                                var addressDict: [[String: Any]] = [[:]]
                                for var address in addresses {
                                    address["value"] = maskedData
                                    addressDict.append(address)
                                }
                                people["addresses"] = addressDict
                            }
                            
                            if let emails = people["emails"] as? [[String: Any]] {
                                var emailDict: [[String: Any]] = [[:]]
                                for var email in emails {
                                    email["value"] = maskedData
                                    emailDict.append(email)
                                }
                                people["emails"] = emailDict
                            }
                            
                            if let phones = people["phones"] as? [[String: Any]] {
                                var phoneDict: [[String: Any]] = [[:]]
                                for var phone in phones {
                                    phone["value"] = maskedData
                                    phoneDict.append(phone)
                                }
                                people["phones"] = phoneDict
                            }
                            people["indicators"] = maskedData
                            verifiedPeople.append(people)
                        }
                        metaData["verifiedPeople"] = verifiedPeople
                    }
                    certificate["metadata"] = metaData
                }
                certificates.append(certificate)
            }
            payload["certifications"] = certificates
        }
        return payload
    }
}
    
    // MARK: - UITextFieldDelegate -
    extension SSNViewController: UITextFieldDelegate {
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.activeTextField = textField
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

    }
