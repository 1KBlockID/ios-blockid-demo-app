//
//  SSNViewController.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 06/01/22.
//

import UIKit

class SSNViewController: UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var txtFieldSSN: UITextField!
    @IBOutlet weak var txtFieldFirstName: UITextField!
    @IBOutlet weak var txtFieldMiddleName: UITextField!
    @IBOutlet weak var txtFieldLastName: UITextField!
    @IBOutlet weak var txtFieldDob: UITextField!
    @IBOutlet weak var txtFieldAddress: UITextField!
    @IBOutlet weak var txtFieldZipCode: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPhoneNo: UITextField!
    @IBOutlet weak var txtFieldState: UITextField!
    @IBOutlet weak var txtFieldCity: UITextField!
    @IBOutlet weak var btnUserConsent: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    
    // MARK: - View LifeCycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - IBOutlets Actions -
    @IBAction func doContinue(_ sender: UIButton) {
        guard let error = isValidInput() else {
            // continue
            return
        }
        self.showAlertView(title: "Alert", message: error)
    }
    
    @IBAction func doBack(_ sender: UIButton) {
        
    }
}


// MARK: - Extension -
extension SSNViewController {
    
    private func setupObservers() {
        
        txtFieldCity.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldSSN.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldDob.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldAddress.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldEmail.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldPhoneNo.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldZipCode.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldState.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldLastName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldFirstName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtFieldMiddleName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        btnContinue.isUserInteractionEnabled = !textField.text!.isEmpty
        btnContinue.backgroundColor = textField.text!.isEmpty ? .darkGray : .black
    }
    
    // TextField Validations
    private func isValidInput() -> String? {
        
        if !txtFieldSSN.text!.isValid(type: .SSN) {
            return "Invalid Social Security Number"
        } else if !txtFieldFirstName.text!.isValid(type: .firstName) {
            return "Invalid First Name"
        } else if !txtFieldLastName.text!.isValid(type: .lastName) {
            return "Invalid Last Name"
        } else if !txtFieldDob.text!.isValid(type: .DOB) {
            return "Invalid Date of Birth"
        } else if !txtFieldEmail.text!.isValid(type: .email) {
            return "Invalid Email Address"
        } else if !txtFieldZipCode.text!.isValid(type: .zipCode) {
            return "Invalid Zip code"
        } else if !txtFieldPhoneNo.text!.isValid(type: .phone) {
            return "Invalid Phone Number"
        }
        
        return nil
    }
    
    private func verifySSN() {
        
        
        
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
        return formatter.string(from: date)
    }
}
