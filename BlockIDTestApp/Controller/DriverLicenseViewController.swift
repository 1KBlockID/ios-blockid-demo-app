//
//  DriverLicenseViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import AVFoundation
import BlockIDSDK
import Toast_Swift
  
class DriverLicenseViewController: UIViewController {

    private var dlScannerHelper: DriverLicenseScanHelper?
    private let selectedMode: ScanningMode = .SCAN_LIVE
    private let firstScanningDocSide: DLScanningSide = .DL_FRONT
    private let expiryDays = 90
    private var _scanLine: CAShapeLayer!
    var debug: Bool = false
    @IBOutlet private weak var _viewBG: UIView!
    @IBOutlet private weak var _viewLiveIDScan: BIDScannerView!
    @IBOutlet private weak var _imgOverlay: UIImageView!
    @IBOutlet private weak var _lblScanInfoTxt: UILabel!
    @IBOutlet weak var _scannedDocument: UITableView!
    var ocr: String = ""
    var face: String = ""
    var doc_image: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        startDLScanning()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.numberOfFacesNotification(_:)), name: NSNotification.Name(rawValue: "BlockIDFaceDetectionNotification"), object: nil)
        _scannedDocument.register(ImageViewCell.self, forCellReuseIdentifier: "imageViewCell")
        _scannedDocument.reloadData()
//        _scannedDocument.delegate = self
        _scannedDocument.dataSource = self

    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "BlockIDFaceDetectionNotification"), object: nil)
    }

    @objc func numberOfFacesNotification(_ notification: Notification) {
        guard let faceCount = notification.userInfo?["numberOfFaces"] as? Int else { return }
        print ("Number of faces found: \(faceCount)")
        DispatchQueue.main.async {
            if faceCount > 0 {
                self._lblScanInfoTxt.text = "Faces found : \(faceCount)"
            } else {
                self._lblScanInfoTxt.text = "Scan Front"
            }
        }
    }

    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Cancellation warning!", message: "Do you want to cancel the registration process?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.dlScannerHelper?.stopDLScanning()
            self.goBack()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        self.present(alert, animated: true)
        return
    }
    
    private func startDLScanning() {
        //1. Check for Camera Permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if !response {
                //2. Show Alert
                DispatchQueue.main.async {
                    self.alertForCameraAccess()
                }
            } else {
                DispatchQueue.main.async {
                    self._viewBG.isHidden = false
                    self._viewLiveIDScan.isHidden = false
                    //3. Initialize dlScannerHelper
                    if self.dlScannerHelper == nil {
                        self.dlScannerHelper = DriverLicenseScanHelper.init(scanningMode: self.selectedMode, bidScannerView: self._viewLiveIDScan, dlScanResponseDelegate: self, cutoutView: self._imgOverlay.frame, expiryGracePeriod: self.expiryDays)
                    }
                    //4. Start Scanning
                    self._lblScanInfoTxt.text = DLScanningSide.DL_BACK == self.firstScanningDocSide ? "Scan Back" : "Scan Front"
                    self.dlScannerHelper?.startDLScanning(scanningSide: self.firstScanningDocSide)

                    self._scanLine = self.addScanLine(self._imgOverlay.frame)
                    self._imgOverlay.layer.addSublayer(self._scanLine)
                }
            }
        }
        
    }
  
    private func setDriverLicense(withDLData dl: [String : Any]?, token: String) {
        self.view.makeToastActivity(.center)
        var dic = dl
        dic?["category"] = RegisterDocCategory.Identity_Document.rawValue
        dic?["type"] = RegisterDocType.DL.rawValue
        dic?["id"] = dl?["id"]
        BlockIDSDK.sharedInstance.registerDocument(obj: dic ?? [:], sigToken: token) { [self] (status, error) in
            DispatchQueue.main.async {
                self.view.hideToastActivity()
                if !status {
                    // FAILED
                    if error?.code == CustomErrors.kLiveIDMandatory.code {
                        DocumentStore.sharedInstance.setData(documentData: dic, token: token)
                        self.goBack()
                        self.showLiveIDView()
                        return
                    }
                    
                    self.view.makeToast(error?.message, duration: 3.0, position: .center, title: "Error", completion: {_ in
                        self.goBack()
                    })
                    return
                }
                // SUCCESS
                self.view.makeToast("Driver License enrolled successfully", duration: 3.0, position: .center, title: "Thank you!", completion: {_ in
                    self.goBack()
                })
            }
        }
    }
    
    private func scanCompleteUIUpdates() {
        self._lblScanInfoTxt.text = "Scan Complete"
        _scanLine.removeAllAnimations()
    }
}

extension DriverLicenseViewController: DriverLicenseResponseDelegate {
    func dlScanCompleted(dlScanSide: DLScanningSide, dictDriveLicense: [String : Any]?, signatureToken signToken: String?, error: ErrorResponse?) {
        if (error as? ErrorResponse)?.code == CustomErrors.kUnauthorizedAccess.code {
            self.showAppLogin()
        }
        //Check If Expired, licenene key not enabled
        if error?.code == CustomErrors.kDocumentExpired.code || error?.code == CustomErrors.kLicenseyKeyNotEnabled.code {
            self.view.makeToast(error?.message, duration: 3.0, position: .center)
            return
        }
        guard let dl = dictDriveLicense else {
            self.view.makeToast(error?.message, duration: 3.0, position: .center)
            return
        }
        if (debug) {
            for (key, value) in dl {
                if (key == "ocr") {
//                    print("\(key) -> \(value)")
                    ocr = value as! String
                } else if (key == "image") {
                    doc_image = value as! String
                } else if (key == "face") {
                    face = value as! String
                }
            }
            _scannedDocument.isHidden = false
            _scannedDocument.reloadData()
            return
        } else {
            if (dlScanSide == firstScanningDocSide) {
                scanBackSide()
            }
        }
        
        scanCompleteUIUpdates()
        guard let token = signToken else {
            self.view.makeToast(error?.message, duration: 3.0, position: .center)
            return
        }
        //Check if Not to Expiring Soon
        if error?.code != CustomErrors.kDocumentAboutToExpire.code {
            self.setDriverLicense(withDLData: dl, token: token)
            return
        }
        
        //About to Expire, Show Alert
        let alert = UIAlertController(title: "Error", message: error!.message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.setDriverLicense(withDLData: dl, token: token)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func scanFrontSide() {
        DispatchQueue.main.async {
            self._lblScanInfoTxt.text = "Scan Front"
            self.dlScannerHelper?.startDLScanning(scanningSide: .DL_FRONT)
        }
    }
    
    func scanBackSide() {
        DispatchQueue.main.async {
            self._lblScanInfoTxt.text = "Scan Back"
            self.dlScannerHelper?.startDLScanning(scanningSide: .DL_BACK)
        }
    }

    func readyForDetection() {
        DispatchQueue.main.async {
            //Check if there are any existing animations
            if !(self._scanLine.animationKeys()?.count ?? 0 > 0) {
                self.animateScanLine(_scanLine: self._scanLine, height:  self._imgOverlay.frame.height)
            }
        }
    }
}

extension DriverLicenseViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0 || indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageViewCell", for: indexPath) as! ImageViewCell
            if (indexPath.row == 1) {
                cell.mainImageView.image = CommonFunctions.convertImageFromBase64String(str: face)
            } else {
                cell.mainImageView.image = CommonFunctions.convertImageFromBase64String(str: doc_image)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.numberOfLines = 0;
            cell.textLabel?.lineBreakMode = .byWordWrapping;
            cell.textLabel?.text = ocr
            return cell
        }
    }
}

extension DriverLicenseViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

class ImageViewCell: UITableViewCell {
    var mainImageView : UIImageView  = {
        var imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    var imageViewHeight = NSLayoutConstraint()
    var imageRatioWidth = CGFloat()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(mainImageView)
        mainImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        mainImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mainImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
