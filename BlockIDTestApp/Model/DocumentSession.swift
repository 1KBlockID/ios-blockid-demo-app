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

public class VerifySessionRequest: NSObject, Codable {
    
    var sessionId: String!
    var dvcID: String!
    init(sessionId: String, dvcID: String) {
        self.sessionId = sessionId
        self.dvcID = dvcID
    }
    
}

public class DocumentSessionResult: Codable {
    public var responseStatus: String?
    public var dlObject: [String: Any]
    
    
    enum CodingKeys: String, CodingKey {
        case dlObject = "dl_object"
        case responseStatus
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if values.contains(.dlObject) {
            dlObject = try values.decode([String: Any].self, forKey: .dlObject)
        } else {
            dlObject = [String: Any]()
        }
        if values.contains(.responseStatus) {
            responseStatus = try values.decode(String?.self, forKey: .responseStatus)
        }
        else {
            responseStatus = ""
        }

    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !dlObject.isEmpty {
            try container.encode(self.dlObject, forKey: .dlObject)
        }
        if let status = responseStatus, !status.isEmpty {
            try container.encode(self.responseStatus, forKey: .responseStatus)
        }
    }
}
