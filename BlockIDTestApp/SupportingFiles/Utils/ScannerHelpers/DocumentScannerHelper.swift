//
//  DocumentScannerHelper.swift
//  ios-kernel
//
//  Created by Prasanna Gupta on 30/11/22.
//  Copyright © 2022 1Kosmos. All rights reserved.
//

import Foundation
import CFDocumentScanSDK
import UIKit
import BlockIDSDK

public typealias DLScanCallback = ((_ status: Bool, _ data: [String: Any]?, _ error: ErrorResponse?) -> Void)

class DocumentScannerHelper {
    
    static let shared = DocumentScannerHelper()
    var scanCompletionHandler: DLScanCallback?

    private lazy var scanHandler = DSHandler(delegate: self)
    
    // set default image compression quality
    private lazy var imageCompressionQuality: Double = 0.5
    
    // set default capture mode to Manual
    private lazy var captureMode: CFDocumentScanSDK.DSCaptureMode = .Manual
    
    // set default document capture side to Front
    private lazy var scanSide: CFDocumentScanSDK.DSSide = .Front
    
    private lazy var scanVC: UIViewController = DocumentScannerViewController()
    private lazy var options = DSID1Options()
    private var documentDic = [String: Any]()

    private init() {}
    
    /// Initialize Driver License Scan
    ///
    /// This func will initialize properties before starting Driver License scan
    ///
    private func initializeDLScan() {
        scanHandler = DSHandler(delegate: self)
        options = DSID1Options()
        options.side = scanSide
        options.showReviewScreen = true
        options.captureMode = captureMode
        options.imageCompressionQuality = imageCompressionQuality
    }
    
    ///  Start Driver License Scan
    ///
    ///  This func will set document scanning side and call initializeDLScan() and will start the scan process
    ///
    /// - Parameter viewController: A parent view controller to present scan
    /// - Parameter documentSide: CFDocumentScanSDK.DSSide type which will decide which side of document will be scanned first
    /// - Parameter completion: DLScanCallback which will send response on scan completion
    ///
    func startDLScan(from viewController: UIViewController, forSide documentSide: CFDocumentScanSDK.DSSide = .Front, completion: DLScanCallback?) {
        
        if appDelegate?.orientationLock == UIInterfaceOrientationMask.portrait {
            CommonFunctions.rotateDeviceWithOrientationMode(.landscapeRight)
        }

        scanSide = documentSide
        scanCompletionHandler = completion
        self.initializeDLScan()
        scanVC = viewController
        if scanSide == .Front {
            documentDic.removeAll()
        }
        
        startScan()
    }
    
    /// Start scan
    ///
    /// This func will present the scanner as per options set
    private func startScan() {
        scanHandler.options = options
        scanVC.present(scanHandler.scanController,
                       animated: true) {
            self.scanHandler.start()
        }
    }
    
    /// Scan Other Side
    ///
    /// This func will Scan other side of the Driver License which is yet to be scanned
    private func scanOtherSide() {
        scanSide = (scanSide == .Front) ? .Back : .Front
        startDLScan(from: scanVC, forSide: scanSide, completion: scanCompletionHandler)
    }
    
    /// Add Scanned data to dic
    ///
    /// This func will add the scanned data to a dictionary.
    ///
    /// - Parameter result: scanned data of type DSResult
    private func addDataToDic(result: DSResult) {
        if scanSide == .Front {
            if !documentDic.keys.contains("front_image") {
                guard let frontImg = result.uncroppedImage else { return }
                documentDic["front_image"] = getBase64FromImageData(imgData: frontImg)
            }
            
            if !documentDic.keys.contains("front_image_flash") {
                guard let flashImg = result.uncroppedFlashImage else { return }
                documentDic["front_image_flash"] = getBase64FromImageData(imgData: flashImg)
            }
            
        } else {
            if !documentDic.keys.contains("back_image") {
                guard let backImg = result.uncroppedImage else { return }
                documentDic["back_image"] = getBase64FromImageData(imgData: backImg)
            }
        }
    }
    
    /// Get base64 string from Image data
    ///
    /// This func will take data of an image and will convert it into a base64 string.
    ///
    /// - Parameter imgData: data of the image as Data
    /// - Returns: A base64 encoded String of image data
    private func getBase64FromImageData(imgData: Data) -> String {
        return imgData.base64EncodedString()
    }
}

extension DocumentScannerHelper: DSHandlerDelegate {
    // Handle scan result
    func handleScan(result: DSResult) {
        if documentDic.isEmpty {
            addDataToDic(result: result)
            scanOtherSide()
            return
        }
        addDataToDic(result: result)
        self.scanCompletionHandler!(true, documentDic, nil)
        if appDelegate?.orientationLock != UIInterfaceOrientationMask.portrait {
            CommonFunctions.rotateDeviceWithOrientationMode(.portrait)
        }
    }
    
    // Capture scan error call back
    func captureError(_ error: DSError) {
        self.scanCompletionHandler!(false,
                                    nil,
                                    ErrorResponse(code: error.errorType.rawValue,
                                                  msg: error.message))
        if appDelegate?.orientationLock != UIInterfaceOrientationMask.portrait {
            CommonFunctions.rotateDeviceWithOrientationMode(.portrait)
        }
    }
    
    // Call back of scan cancelled
    func scanWasCancelled() {
        self.scanCompletionHandler!(false, nil, nil)
        if appDelegate?.orientationLock != UIInterfaceOrientationMask.portrait {
            CommonFunctions.rotateDeviceWithOrientationMode(.portrait)
        }
    }
}
