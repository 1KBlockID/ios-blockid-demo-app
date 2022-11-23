//
//  LivenessCheck.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 13/05/22.
//

import Foundation

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

class LivenessCheckError: NSObject, Codable {
    var error: String?
    var message: String?
    var status: Int?
    
    enum CodingKeys: String, CodingKey {
        case error
        case message
        case status
    }
}

