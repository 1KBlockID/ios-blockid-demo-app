//
//  RecoverMnemonicsViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//

import UIKit
import BlockID

class RecoverMnemonicsViewController: UIViewController {

    var strMnemonic = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        if let str = BlockIDSDK.sharedInstance.getMnemonicPhrases() {
            self.strMnemonic = str
            let arrMnemonics = str.components(separatedBy: " ")
            var index = 1
            for mnemonic in arrMnemonics {
                if let txtField = self.view.viewWithTag(index) as? UITextField {
                    txtField.text = mnemonic
                }
                index = index+1
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func moveBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func copyToClipboardAction(_ sender: UIButton){
        let pasteboard = UIPasteboard.general
        pasteboard.string = self.strMnemonic
        self.showAlertView(title: "Success", message: "Mnemonic phrase has been copied")
    }
    
}
