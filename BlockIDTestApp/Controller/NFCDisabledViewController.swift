//
//  NFCDisabledViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import UIKit

protocol NFCDisabledViewControllerDelegate {
    func cancelRFID()
}
class NFCDisabledViewController: UIViewController {

    public var delegate : NFCDisabledViewControllerDelegate?
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK:-
    @IBAction func onSettings(_ sender: UIButton) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
            })
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        let alert = UIAlertController(title: "Warning!", message: "Do you want to cancel RFID Scan?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            
            self.navigationController?.popViewController(animated: true)
            self.delegate?.cancelRFID()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
}
