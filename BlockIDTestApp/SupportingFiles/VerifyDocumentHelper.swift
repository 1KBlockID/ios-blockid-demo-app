//
//  VerifyDocumentHelper.swift
//  ios-kernel
//
//  Created by Prasanna on 30/11/22.
//  Copyright © 2022 1Kosmos. All rights reserved.
//

import Foundation
import BlockIDSDK

public typealias LivenessCheckCallback = ((_ status: Bool, _ error: ErrorResponse?) -> Void)
public typealias CompareFaceCallback = ((_ status: Bool, _ error: ErrorResponse?) -> Void)

class VerifyDocumentHelper {
    
    // MARK: - Singleton
    static let shared = VerifyDocumentHelper()
    
    private let kFaceLiveness = "face_liveness"
    private let kFaceCompare = "face_compare"
    let kID = "id"
    let kType = "type"
    let kTypeLiveId = "liveid"
    let kLiveId = "liveId"
    private let kImage1 = "image1"
    private let kImage2 = "image2"
    let kPurpose = "purpose"
    let kPurposeDocEnrollment = "doc_enrollment"
    let kCertifications = "certifications"
    let kVerified = "verified"
    let kCategory = "category"
    
    private init() { }
    
    func checkLiveness(liveIDBase64: String, completion: @escaping LivenessCheckCallback) {
        var livenessCheckDic = [String: Any]()
        livenessCheckDic[kID] = BlockIDSDK.sharedInstance.getDID() + "." + kTypeLiveId
        livenessCheckDic[kType] = kTypeLiveId
        livenessCheckDic[kLiveId] = liveIDBase64
        
        BlockIDSDK.sharedInstance.verifyDocument(dic: livenessCheckDic,
                                                 verifications: [kFaceLiveness]) { status, dataDic, error in
            if !status {
                completion(status, error)
                return
            }
            
            var verified = false
            
            if let dataDict = dataDic,
               let certifications = dataDict[self.kCertifications] as? [[String: Any]] {
                if let isVerified = certifications[0][self.kVerified] as? Bool, isVerified {
                    verified = isVerified
                }
            }
            
            if !verified {
                completion(false, ErrorResponse(code: CustomErrors.kFaceLivenessCheckFailed.code, msg: CustomErrors.kFaceLivenessCheckFailed.msg))
                return
            }
            completion(true, nil)
        }
    }
    
    func compareFace(base64Image1: String, base64Image2: String, completion: @escaping CompareFaceCallback) {
        var faceCompareDic = [String: Any]()
        faceCompareDic[kID] = BlockIDSDK.sharedInstance.getDID() + "." + kFaceCompare
        faceCompareDic[kType] = kFaceCompare
        faceCompareDic[kImage1] = base64Image1
        faceCompareDic[kImage2] = base64Image2
        faceCompareDic[kPurpose] = kPurposeDocEnrollment

        BlockIDSDK.sharedInstance.verifyDocument(dic: faceCompareDic,
                                                 verifications: [kFaceCompare]) { status, dataDic, error in
            if !status {
                completion(status, error)
                return
            }
            
            var verified = false
            
            if let dataDict = dataDic,
               let certifications = dataDict[self.kCertifications] as? [[String: Any]] {
                if let isVerified = certifications[0][self.kVerified] as? Bool, isVerified {
                    verified = isVerified
                }
            }
            
            if !verified {
                completion(false, ErrorResponse(code: CustomErrors.kDocumentPhotoComparisionFailed.code,
                                                msg: CustomErrors.kDocumentPhotoComparisionFailed.msg))
                return
            }
            completion(true, nil)
            
        }
    }
}
