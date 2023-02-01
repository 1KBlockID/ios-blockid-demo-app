//
//  EPassportChipScanViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import BlockID


protocol EPassportChipScanViewControllerDelegate {
    func onScan()
    func onSkip()
}
class EPassportChipScanViewController: UIViewController {

    public var delegate : EPassportChipScanViewControllerDelegate?
    
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func onSkip(_ sender: UIButton) {

        
        let alert = UIAlertController(title: "Warning!", message: "Do you want to cancel RFID Scan?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            //skip RFID
            self.delegate?.onSkip()
            self.navigationController?.popViewController(animated: true)
           
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        self.present(alert, animated: true)
        return
    }
    
    @IBAction func onScan(_ sender: UIButton) {
        self.delegate?.onScan()
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
