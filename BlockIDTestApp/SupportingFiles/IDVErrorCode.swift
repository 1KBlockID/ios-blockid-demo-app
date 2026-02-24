//
//  IDVErrorCode.swift
//  1Kosmos Demo
//
//  Created by Prasanna Gupta on 18/02/26.
//

import Foundation

enum IDVErrorCode: String, LocalizedError {
    
    case imageQualityCheckFailed        = "IDV0001"
    case verificationPartiallyCompleted = "IDV0002"
    case verificationFrontOnly          = "IDV0003"
    case extractionFailed               = "IDV0004"
    case incorrectDocumentType          = "IDV0005"
    case unsupportedDocument            = "IDV0006"
    case dataCheckFailed                = "IDV0007"
    case documentLivenessFailed         = "IDV0008"
    case documentValidityFailed         = "IDV0009"
    case moduleFailed                   = "IDV0010"
    case documentExpired                = "IDV0011"
    case fraudCheckFailed               = "IDV0012"
    case retryAttemptsExhausted         = "IDV0014"
    case documentNotAllowed             = "IDV0015"
    
    private var message: String {
            switch self {
                
            case .imageQualityCheckFailed:
                return "Scan failed. Please check the surroundings and try scanning again."
                
            case .verificationPartiallyCompleted,
                 .verificationFrontOnly,
                 .extractionFailed,
                 .documentLivenessFailed,
                 .documentValidityFailed,
                 .fraudCheckFailed:
                return "We couldn’t complete the verification of the document. Please try again."
                
            case .unsupportedDocument,
                 .documentNotAllowed:
                return "Unsupported document. Please scan a valid document."
                
            case .incorrectDocumentType:
                return "Scan failed. Please scan a valid document."
                
            case .dataCheckFailed,
                 .moduleFailed:
                return "We couldn’t complete the verification. Please try again."
                
            case .documentExpired:
                return "The document you are trying to enroll is already expired."
                
            case .retryAttemptsExhausted:
                return "You have exhausted all retry attempts. Please try again later."
            }
    }
    
    var errorDescription: String? {
        return "\(message) [\(rawValue)]"
    }
}
