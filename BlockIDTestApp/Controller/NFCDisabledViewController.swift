//
//  NFCDisabledViewController.swift
//  BlockIDTestApp
//
//  Created by vaidehi hindlekar on 04/05/21.
//

import Foundation
import UIKit


class NFCDisabledViewController: UIViewController {
    
    var onCallback: ((_ sender : UIViewController, _ status: Bool) -> Void)?

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
            //self.setDriverLicense(withDLData: dl, token: token)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
}
