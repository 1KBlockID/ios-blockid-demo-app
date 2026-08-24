//
//  GetSessionAuthModelAPI.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import Alamofire

public class GetSessionAuthModelAPI {
    static let sharedInstance = GetSessionAuthModelAPI()
    let kSessionAuthModelNotFound: (code: Int, message: String) = (1006, "Session auth model not found")

    private init() {
    }

    public func getSessionAuthRequest(url: String, completion: @escaping ((_ isSuccess: Bool, _ response: String?, _ message: String) -> Void)) {

        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { [self] response in
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        completion(false, nil, kSessionAuthModelNotFound.1)
                        return
                    }
                    let strResponse = String(decoding: data, as: UTF8.self)
                    completion(true, strResponse, "Data fetched successfully.")
                case .failure(let error):
                    completion(false, nil, error.localizedDescription)
                }
            }
    }
}
