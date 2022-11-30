//
//  SelfieScannerHelper.swift
//  ios-kernel
//
//  Created by Kuldeep Choudhary on 11/04/22.
//  Copyright © 2022 1Kosmos. All rights reserved.
//

import Foundation
import IDMetricsSelfieCapture
import UIKit
import BlockIDSDK

public typealias SelfieScanCallback = ((_ status: Bool, _ data: [String: Any]?, _ error: ErrorResponse?) -> Void)

class SelfieScannerHelper: NSObject {

    static let shared = SelfieScannerHelper()
    private var scanCompletionHandler: SelfieScanCallback?

    private lazy var selfieHandler = CFASelfieController.sharedInstance() as? CFASelfieController
    private lazy var imageCompressionQuality: Int32 = 90
    private lazy var captureMode: CFASelfieCaptureMode = .ManualCapture
    private lazy var scanVC: UIViewController = SelfieScannerViewController()
    private var liveIDImgDic = [String: Any]()

    private override init() {}
    
    /// LiveID Scan Initialization
    ///
    /// This func will initialize the near and far selfie settings before starting the scan and will initiate scan later.
    ///
    /// - Parameter viewController: A parent view controller to present scan
    /// - Parameter completion: SelfieScanCallback which will send response on scan completion
    ///
    func startLiveIDScan(from viewController: UIViewController, completion: SelfieScanCallback?) {
        let selfieSettings = CFASelfieSettings()
        selfieSettings?.captureMode = captureMode
        selfieSettings?.enableFarSelfie = false
        selfieSettings?.compressionQuality = imageCompressionQuality
        selfieSettings?.enableSwitchCamera = false
        
        scanCompletionHandler = completion
        
        if appDelegate?.orientationLock != UIInterfaceOrientationMask.portrait {
            CommonFunctions.rotateDeviceWithOrientationMode(.portrait)
        }
        
        selfieHandler?.scanSelfie(viewController,
                                  selfieSettings: selfieSettings,
                                  selfieScanDelegate: self)
    }

}

// MARK: - CFASelfieScanDelegate
extension SelfieScannerHelper: CFASelfieScanDelegate {
    
    func onFinishSelfieScan(_ selfieScanData: CFASelfieScanData!) {        
        if let selfieData = selfieScanData.selfieData {
            liveIDImgDic["liveId"] = selfieData.base64EncodedString()
        }
        self.scanCompletionHandler!(true, liveIDImgDic, nil)
    }
    
    func onCancelSelfieScan() {
        self.scanCompletionHandler!(false, nil, nil)
    }
    
    func onFinishSelfieScanWithError(_ errorCode: Int32, errorMessage: String!) {
        self.scanCompletionHandler!(false, nil, ErrorResponse(code: Int(errorCode), msg: errorMessage))
    }

}
