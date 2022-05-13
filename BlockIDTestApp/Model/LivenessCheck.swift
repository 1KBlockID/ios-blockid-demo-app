//
//  LivenessCheck.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 13/05/22.
//

import Foundation

//{
//    "liveness_score": 5.970656,
//    "quality_score": 0.6582916,
//    "liveness_probability": 1.0,
//    "status_code": "OK"
//}

class LivenessCheck: NSObject, Codable {
    
    var livenessScore: Double?
    var qualityScore: Double?
    var livnessProbability: Double?
    var statusCode: String?
    
    enum CodingKeys: String, CodingKey {
        case livenessScore = "liveness_score"
        case qualityScore = "quality_score"
        case livnessProbability = "liveness_probability"
        case statusCode = "status_code"
    }
    
}



