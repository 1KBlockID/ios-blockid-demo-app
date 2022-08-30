//
//  ScanQRViewController.swift
//  BlockIDTestApp
//
//  Created by Kuldeep Choudhary on 24/08/22.
//

import UIKit
import Foundation
import AVFoundation
import BlockIDSDK

protocol ScanQRViewDelegate: AnyObject {
    func scannedData(data: String)
}

class ScanQRViewController: UIViewController {
    
    weak var delegate: ScanQRViewDelegate?
    
    private let selectedMode: ScanningMode = .SCAN_LIVE
    private var qrScannerHelper: QRScannerHelper?

    @IBOutlet weak var _viewQRScan: BIDScannerView!
        
    override func viewWillAppear(_ animated: Bool) {
        self.scanQRCode()
    }
    
    private func scanQRCode() {
        qrScannerHelper = QRScannerHelper.init(scanningMode: selectedMode, bidScannerView: _viewQRScan, kQRScanResponseDelegate: self)
        qrScannerHelper?.startQRScanning()
    }
}

extension ScanQRViewController: QRScanResponseDelegate {
    func onQRScanResult(qrCodeData: String?) {
        if qrCodeData == nil {

            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if !response {
                    DispatchQueue.main.async {
                        self.alertForCameraAccess()
                    }
                }
            }
            return
        }
        qrScannerHelper?.stopQRScanning()
        
        if let delegate = self.delegate {
            delegate.scannedData(data: qrCodeData ?? "invalid")
        }
        self.dismiss(animated: true)
    }
}
