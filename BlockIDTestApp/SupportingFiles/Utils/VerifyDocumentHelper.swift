//
//  VerifyDocumentHelper.swift
//  ios-kernel
//
//  Created by Prasanna on 30/11/22.
//  Copyright © 2022 1Kosmos. All rights reserved.
//

import Foundation
import BlockIDSDK

public typealias LivenessCheckCallback = ((_ status: Bool,
                                           _ error: ErrorResponse?) -> Void)
public typealias CompareFaceCallback = ((_ status: Bool,
                                         _ error: ErrorResponse?) -> Void)
public typealias AuthenticateDocumentCallback = ((_ status: Bool,
                                      _ documentData: [String: Any]?,
                                      _ error: ErrorResponse?) -> Void)

class VerifyDocumentHelper {
    
    // MARK: - Singleton
    static let shared = VerifyDocumentHelper()
    private let k_COMPARE_FACE_FAILED_CODE = 101
    let k_AUTHENTICATE_DOCUMENT_FAILED_CODE = 102
    
    private let kFaceLiveness = "face_liveness"
    private let kFaceCompare = "face_compare"
    private let kDLAuthenticate = "dl_authenticate"
    
    let kID = "id"
    let kType = "type"
    let kTypeLiveId = "liveid"
    let kTypeDL = "dl"
    let kLiveId = "liveId"
    let kImage1 = "image1"
    let kImage2 = "image2"
    let kPurpose = "purpose"
    let kPurposeValue = "doc_enrollment"
    let kCertifications = "certifications"
    let kVerified = "verified"
    let kCategory = "category"
    
    private init() { }
    
    /// Compares scanned face with registered face
    ///
    /// - Parameters
    ///    - base64Image1: base64 encoded image1
    ///    - base64Image2: base64 encoded image2
    ///
    func compareFace(base64Image1: String,
                     base64Image2: String,
                     completion: @escaping CompareFaceCallback) {
        var faceCompareDictionary = [String: Any]()
        faceCompareDictionary[kID] = BlockIDSDK.sharedInstance.getDID() + "." + kFaceCompare
        faceCompareDictionary[kType] = kFaceCompare
        faceCompareDictionary[kImage1] = base64Image1
        faceCompareDictionary[kImage2] = base64Image2
        faceCompareDictionary[kPurpose] = kPurposeValue

        BlockIDSDK.sharedInstance.verifyDocument(dic: faceCompareDictionary,
                                                 verifications: [kFaceCompare])
        { status, dataDictionary, error in
            if !status {
                completion(status, error)
                return
            }
            
            var verified = false
            
            if let dataDict = dataDictionary,
               let certifications = dataDict[self.kCertifications] as? [[String: Any]] {
                if let isVerified = certifications[0][self.kVerified] as? Bool, isVerified {
                    verified = isVerified
                }
            }
            
            if !verified {
                completion(false, ErrorResponse(code: self.k_COMPARE_FACE_FAILED_CODE,
                                                msg: "COMPARE_FACE_FAILED".localizedMessage()))
                return
            }
            completion(verified, nil)
            
        }
    }
    
    /// Authenticate DL data before registration
    ///
    /// This func will verify the scanned Driver License against an authenticator
    ///
    /// - Parameter driverLicense: A Driver License data dictionary
    ///
    func authenticateDriversLicense(withDLData driverLicense: [String: Any]?,
                  completion: @escaping AuthenticateDocumentCallback) {
        var verifications: [String] = []
        guard var dataDictionary = driverLicense else {
            completion(false, nil, nil)
            return
        }
        dataDictionary[VerifyDocumentHelper.shared.kType] = kTypeDL
        dataDictionary[VerifyDocumentHelper.shared.kID] = BlockIDSDK.sharedInstance.getDID() + ".dl"
        verifications = [VerifyDocumentHelper.shared.kDLAuthenticate]
        
        BlockIDSDK.sharedInstance.verifyDocument(dic: dataDictionary,
                                                 verifications: verifications)
        { (status, dataDictionary, error) in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    if !status {
                        // Verification failed
                        completion(status, nil, error)
                        return
                    }
                    
                    if let dataDict = dataDictionary,
                       let certifications = dataDict[VerifyDocumentHelper.shared.kCertifications] as? [[String: Any]]
                    {
                        if let isVerified = certifications[0][VerifyDocumentHelper.shared.kVerified] as? Bool,
                           isVerified == true {
                            guard let dlObjDictionary = certifications[0]["result"] as? [String: Any] else {
                                completion(false, nil, ErrorResponse(code: self.k_AUTHENTICATE_DOCUMENT_FAILED_CODE,
                                                                     msg: "AUTHENTICATE_DOCUMENT_FAILED".localizedMessage()))
                                return
                            }
                            completion(true, dlObjDictionary, nil)
                            return
                        }
                    }
                    
                    completion(false, nil, ErrorResponse(code: self.k_AUTHENTICATE_DOCUMENT_FAILED_CODE,
                                                          msg: "AUTHENTICATE_DOCUMENT_FAILED".localizedMessage()))
                }
            }
        }
    }
}
