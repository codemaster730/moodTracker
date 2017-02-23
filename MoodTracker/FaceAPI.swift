//
//  FaceAPI.swift
//  MoodTracker
//
//  Created by axiom88 06/10/2016.
//  Copyright © 2016 Axiom. All rights reserved.
//

import UIKit

enum FaceAPIResult<T, Error> {
    case success(T)
    case failure(Error)
}


class FaceAPI: NSObject {

    // Detect Face
    
    static func detectFaces(_ facesPhoto: UIImage, completion: @escaping (_ result: FaceAPIResult<AnyObject, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=true&returnFaceAttributes=age,gender,smile"
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let pngRepresentation = UIImagePNGRepresentation(facesPhoto)
        
        let task = URLSession.shared.uploadTask(with: request as URLRequest, from: pngRepresentation, completionHandler: { (data, response, error) in
            
            if let nsError = error {
                completion(.failure(Error.unexpectedError(nsError: nsError as NSError?)))
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    if statusCode == 200 {
                        completion(.success(json as AnyObject))
                    }
                    else {
                        completion(.failure(Error.serviceError(json: json as! [String : AnyObject])))
                    }
                }
                catch {
                    completion(.failure(Error.jSonSerializationError))
                }
            }
        })
        task.resume()
    }
    
    // Find Similar Face
    
    static func findSimilarFaces(_ faceId: String, faces faceIds: [String], completion: @escaping (_ result: FaceAPIResult<AnyObject, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/findsimilars"
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        
        let json: [String: AnyObject] = ["faceId": faceId as AnyObject,
                                         "maxNumOfCandidatesReturned": 20 as AnyObject,
                                         "confidenceThreshold": 0.7 as AnyObject,
                                         "faceIds": faceIds as AnyObject,
                                         "mode":"matchPerson" as AnyObject
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let nsError = error {
                completion(.failure(Error.unexpectedError(nsError: nsError as NSError?)))
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    if statusCode == 200 {
                        completion(.success(json as AnyObject))
                    }
                    else {
                        completion(.failure(Error.serviceError(json: json as! [String : AnyObject])))
                    }
                }
                catch {
                    completion(.failure(Error.jSonSerializationError))
                }
            }
        })
        task.resume()
    }
}
