//
//  DocumentSession.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 01/06/22.
//

import Foundation


public class DocumentSessionResponse: Codable {
    public var sessionId: String?
    public var url: String?
}

public class DocumentSessionRequest: Codable {
    
    var dvcID: String!
    var sessionRequest: [String: Any]
    
    init(dvcID: String, sessionRequest: [String: Any]) {
        self.dvcID = dvcID
        self.sessionRequest = sessionRequest
    }
    
    enum CodingKeys: String, CodingKey {
        case sessionRequest, dvcID
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if values.contains(.sessionRequest) {
            sessionRequest = try values.decode([String: Any].self, forKey: .sessionRequest)
        } else {
            sessionRequest = [String: Any]()
        }
        if values.contains(.dvcID) {
            dvcID = try values.decode(String?.self, forKey: .dvcID)
        }
        else {
            dvcID = ""
        }

    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !sessionRequest.isEmpty {
            try container.encode(self.sessionRequest, forKey: .sessionRequest)
        }
        if !dvcID.isEmpty {
            try container.encode(self.dvcID, forKey: .dvcID)
        }
    }
}


public class DataSessionRequest: NSObject, Codable {
    var data: String!
    
    init(data: String) {
        self.data = data 
    }
}
