//
//  DocumentLivenessViewController.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 13/05/22.
//

import UIKit

class DocumentLivenessViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captureBtn: UIButton!
    
    var onLivenessFinished: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func didTapButton(_ sender: UIButton) {
        
        guard sender.currentTitle == "Take Picture" else {
            documentLivenessAPI()
            return
        }
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = true
            present(picker, animated: true)
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.goBack()
    }
    
    private func documentLivenessAPI() {
        
        self.view.makeToastActivity(.center)
        if let image = imageView.image {
            DocumentLiveness.sharedInstance.checkLiveness(reqParameter: image) { [weak self] success, dataModel, error in
                guard let weakSelf = self else {return}
                weakSelf.view.hideToastActivity()
                guard error == nil else {
                    weakSelf.view.makeToast(error?.localizedDescription, duration: 3.0, position: .center, title: "Error", completion: {_ in
                        weakSelf.goBack()
                    })
                    return
                }
                
                if success {
                    guard let statusCode = dataModel?.statusCode, statusCode.lowercased() == "ok"  else {
                        weakSelf.view.makeToast(dataModel?.statusCode, duration: 3.0, position: .center, title: "Error", completion: {_ in
                            weakSelf.goBack()
                        })
                        return
                    }
                    //livenessProb > 0.5
                    if let livenessProb = dataModel?.livnessProbability, livenessProb > 0.5 {
                       // weakSelf.navigationController?.popViewController(animated: true)
                        // start DL scanning ....
                        if let onLivenessFinished = weakSelf.onLivenessFinished {
                            onLivenessFinished()
                        }
                        
                    }  else {
                        weakSelf.view.makeToast("Liveness does not match the minimum required score.", duration: 3.0, position: .center, title: "Error", completion: {_ in
                            weakSelf.goBack()
                        })
                    }
                } else {
                    // handle failure use cases 
                }
                
            }
        }

    }

    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension DocumentLivenessViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        imageView.image = image
        self.captureBtn.setTitle("Verify Document", for: .normal)
    }
}
