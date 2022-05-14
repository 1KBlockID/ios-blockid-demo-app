//
//  DocumentLivenessViewController.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 13/05/22.
//

import UIKit

class DocumentLivenessViewController: UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captureBtn: UIButton!
    
    // MARK: - Callbacks -
    var onLivenessFinished: ((UIViewController?) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions -
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
    
    
    // MARK: - Private Methods -
    // API for IDRND document liveness check...
    private func documentLivenessAPI() {
        
        self.view.makeToastActivity(.center)
        if let image = imageView.image {
            DocumentLiveness.sharedInstance.checkLiveness(reqParameter: image) { [weak self] success, dataModel, errorModel ,errorStr in
                guard let weakSelf = self else {return}
                weakSelf.view.hideToastActivity()
                guard errorStr == nil else {
                    weakSelf.view.makeToast(errorStr, duration: 3.0, position: .center, title: "Error", completion: {_ in
                        weakSelf.goBack()
                    })
                    return
                }
                
                if let errModel = errorModel {
                    let message = (errModel.message ?? "Something went wrong")
                    let code = ": \(errModel.status ?? 400)"
                    let title = errModel.error ?? "Error"
                    weakSelf.view.makeToast(message, duration: 3.0, position: .center, title: title+code, completion: {_ in
                        weakSelf.goBack()
                    })
                    return
                }
                
                    guard let statusCode = dataModel?.statusCode, statusCode.lowercased() == "ok"  else {
                        weakSelf.view.makeToast(dataModel?.statusCode, duration: 3.0, position: .center, title: "Error", completion: {_ in
                            weakSelf.goBack()
                        })
                        return
                    }
                    // Mandatory: livenessProb should be > 0.5 to pass the liveness check
                    if let livenessProb = dataModel?.livnessProbability, livenessProb > 0.5 {
                        // start DL scanning ....
                        if let onLivenessFinished = weakSelf.onLivenessFinished {
                            onLivenessFinished(weakSelf)
                            return
                        }
                        
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        if let dlVC = storyBoard.instantiateViewController(withIdentifier: "DriverLicenseViewController") as? DriverLicenseViewController {
                            dlVC.isLivenessNeeded = true
                            if var vcArray = weakSelf.navigationController?.viewControllers {
                                vcArray.removeLast()
                                vcArray.append(dlVC)
                                weakSelf.navigationController?.setViewControllers(vcArray, animated: false)
                            }
                        }
                        
                    }  else {
                        weakSelf.view.makeToast("Liveness does not match the minimum required score.", duration: 3.0, position: .center, title: "Error", completion: {_ in
                            weakSelf.goBack()
                        })
                    }
            }
        }
    }
    
    // Pop to home view screen...
    private func goBack() {
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController.isKind(of: EnrollMentViewController.self) {
                    self.navigationController?.popToViewController(viewController, animated: true)
                }
            }
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
}


// MARK: - Extension: UIImagePickerControllerDelegate -
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
