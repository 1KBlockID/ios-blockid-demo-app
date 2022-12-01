//
//  SelfieScannerHelper.swift
//  ios-kernel
//
//  Created by Prasanna Gupta on 30/11/22.
//  Copyright © 2022 1Kosmos. All rights reserved.
//

import Foundation
import IDMetricsSelfieCapture
import UIKit
import BlockIDSDK

public typealias SelfieScanCallback = ((_ status: Bool,
                                        _ data: [String: Any]?,
                                        _ error: ErrorResponse?) -> Void)

class SelfieScannerHelper: NSObject {

    static let shared = SelfieScannerHelper()
    private var scanCompletionHandler: SelfieScanCallback?
    let kLiveID = "liveId"
    private lazy var selfieHandler = CFASelfieController.sharedInstance() as? CFASelfieController
    
    // set default image compression quality
    private lazy var imageCompressionQuality: Int32 = 90
    
    // set default capture mode to Manual
    private lazy var captureMode: CFASelfieCaptureMode = .ManualCapture
    
    private lazy var scanVC: UIViewController = SelfieScannerViewController()
    private var selfiePayload = [String: Any]()

    private override init() {}
    
    /// LiveID Scan Initialization
    ///
    /// This func will initialize the near and far selfie settings before starting the scan and will initiate scan later.
    ///
    /// - Parameters-
    ///     - viewController: A parent view controller to present scan
    ///     - completion: SelfieScanCallback which will send response on scan completion
    ///
    func startLiveIDScan(from viewController: UIViewController,
                         completion: SelfieScanCallback?) {
        // create and configure selfie settings
        let selfieSettings = CFASelfieSettings()
        
        // capture mode is set to Manual mode
        // can change to auto mode
        selfieSettings?.captureMode = captureMode
        
        // disable far-selfie option
        selfieSettings?.enableFarSelfie = false
        
        // set compression quality for selfie image
        selfieSettings?.compressionQuality = imageCompressionQuality
        
        // do not show an option to switch camera for taking selfie
        selfieSettings?.enableSwitchCamera = false
        
        scanCompletionHandler = completion
        
        // This is used when doocument scan is verifing liveid as well
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
    // This function will call when scan process will finish
    func onFinishSelfieScan(_ selfieScanData: CFASelfieScanData!) {        
        if let selfieData = selfieScanData.selfieData {
            selfiePayload[kLiveID] = selfieData.base64EncodedString()
            self.scanCompletionHandler!(true,
                                        selfiePayload,
                                        nil)
        } else {
            self.scanCompletionHandler!(false,
                                        nil,
                                        nil)
        }
       
    }
    
   // This function will call when there is some error in the process of scan
    func onFinishSelfieScanWithError(_ errorCode: Int32,
                                     errorMessage: String!) {
        self.scanCompletionHandler!(false,
                                    nil,
                                    ErrorResponse(code: Int(errorCode),
                                                  msg: errorMessage))
    }
    
    // This function will be called when cancel button on scanner screen clicked
    func onCancelSelfieScan() {
        self.scanCompletionHandler!(false,
                                    nil,
                                    nil)
    }
    

}
