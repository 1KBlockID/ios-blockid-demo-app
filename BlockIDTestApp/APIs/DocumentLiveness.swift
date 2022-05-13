//
//  DocumentLiveness.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 13/05/22.
//

import Foundation
import Alamofire


public class DocumentLiveness {
    
    static let sharedInstance = DocumentLiveness()
    static let kBaseURL = "https://idlivedoc-rest-api.idrnd.net/check_liveness"
    
    
    func checkLiveness(reqParameter: UIImage, onCompletion: @escaping (Bool, LivenessCheck?, Error?) -> ()) {
        
        let headers: HTTPHeaders = ["x-api-key": "zSnHCHQwaG4SU3U63IEKblZQoQStdis4e4pijad0",
                                    "Content-type": "multipart/form-data"]
        
        guard let imgData = reqParameter.jpegData(compressionQuality: 0.2) else {
            onCompletion(false ,nil, nil)
            return
        }
        //let parameter = ["file": imgData]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            //Parameter for Upload files
            multipartFormData.append(imgData, withName: "file",fileName: "file.jpg" , mimeType: "image/jpg")
            
            //                    for (key, value) in parameter
            //                    {
            //
            //                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            //                    }
            
        }, usingThreshold:UInt64.init(),
                         to: DocumentLiveness.kBaseURL,
                         method: .post,
                         headers: headers, //pass header dictionary here
                         encodingCompletion: { (result) in
            
            switch result {
            case .success(let upload, _, _):
                print("the status code is :")
                //                            upload.uploadProgress(closure: { (progress) in
                //                                print("something")
                //                            })
                
                upload.responseJSON { response in
                    print("the resopnse code is : \(response.response?.statusCode)")
                    print("the response is : \(response)")
                    guard let data = response.data else {
                        return
                    }
                    let decoder = JSONDecoder()
                    if let obj = try? decoder.decode(LivenessCheck.self, from: data) {
                        onCompletion(true, obj, nil)
                    }
                }
            case .failure(let encodingError):
                print("the error is  : \(encodingError.localizedDescription)")
                onCompletion(false ,nil, encodingError)
            }
        })
    }
    
}

