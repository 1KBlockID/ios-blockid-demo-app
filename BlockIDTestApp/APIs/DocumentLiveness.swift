//
//  DocumentLiveness.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 13/05/22.
//

import Foundation
import Alamofire
import UIKit


public class DocumentLiveness {
    
    //  - Singleton Object -
    static let sharedInstance = DocumentLiveness()
    // Computed Properties
    static var kBaseURL: String {
        return "https://idlivedoc-rest-api.idrnd.net/check_liveness"
    }
    static var kXAPIKey: String {
        return "zSnHCHQwaG4SU3U63IEKblZQoQStdis4e4pijad0"
    }
    
    // MARK: - Liveness Check API -
    func checkLiveness(reqParameter: UIImage, onCompletion: @escaping (Bool, LivenessCheck?, LivenessCheckError?, String?) -> ()) {
        
        let headers: HTTPHeaders = ["x-api-key": DocumentLiveness.kXAPIKey,
                                    "Content-type": "multipart/form-data"]
        
        guard let imgData = reqParameter.jpegData(compressionQuality: 0.2) else {
            onCompletion(false ,nil, nil, nil)
            return
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            //Parameter for Upload files
            multipartFormData.append(imgData, withName: "file",fileName: "file.jpg" , mimeType: "image/jpg")
            
        }, to: DocumentLiveness.kBaseURL,
           method: .post,
           headers: headers)
            .responseJSON { response in
                print("the response is : \(response)")
                if let error = response.error, let urlError = error.underlyingError as? URLError, (urlError.code == URLError.dataNotAllowed || urlError.code == URLError.notConnectedToInternet) {
                    let noInternet = "Please check your internet connection."
                    onCompletion(false, nil, nil, noInternet)
                    return
                }
                
                guard let data = response.data else {
                    return
                }
                let decoder = JSONDecoder()
                
                if let obj = try? decoder.decode(LivenessCheckError.self, from: data),
                   obj.status != nil, obj.message != nil {
                    onCompletion(true, nil, obj, nil)
                    return
                }

                if let obj = try? decoder.decode(LivenessCheck.self, from: data) {
                    onCompletion(true, obj, nil, nil)
                }
            }
    }
    
}
