//
//  MySafariViewController.swift
//  BlockIDTestApp
//
//  Created by Prasanna Gupta on 22/11/23.
//

import UIKit
import SafariServices

class MySafariViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var txtFieldObject: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    fileprivate func loadURL(_ url: String) {
        let url = URL(string: url)!
        let controller = SFSafariViewController(url: url)
        self.present(controller, animated: true, completion: nil)
        controller.delegate = self
    }
    
    @IBAction func submitURL(_ sender: UIButton) {
        guard let urlString = txtFieldObject.text, !urlString.isEmpty else {
            return
        }
        
        // Check for valid url
        if isValidUrl(urlString: urlString) {
            loadURL(txtFieldObject.text ?? "")
        }
    }
    
    
    @IBAction func moveBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func isValidUrl(urlString: String) -> Bool {
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
