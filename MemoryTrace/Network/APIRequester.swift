//
//  APIRequester.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/12.
//

import Alamofire

struct APIRequester {
    typealias Completion<T> = (Result<T, AFError>) -> Void
    
    let router: Router
    private let token = UserManager.jwt
    
    init(with router: Router) {
        self.router = router
        AF.session.configuration.timeoutIntervalForRequest = 5
    }
    
    func getRequest<T: Codable> (completion: @escaping Completion<T>) {
        let request = AF.request(router.url, method: .get, headers: ["Authorization": token ?? "No value"]
        )
        
        request.responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    func multiPartRequest<T: Codable> (imageName: String, data: Data? = nil, method: HTTPMethod  ,completion: @escaping Completion<T>) {
        AF.upload(multipartFormData: { multiPart in
            if data != nil {
                multiPart.append(data!, withName: imageName, fileName: "image.png", mimeType: "image/png")
            }
            for (key, value) in router.parameters {
                multiPart.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: router.url, method: method, headers: ["Authorization": token ?? "No value"]).responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    func postRequest<T: Codable> (completion: @escaping Completion<T>) {
        let request: DataRequest!
        
        if token != nil {
            request = AF.request(router.url, method: .post, parameters: router.parameters, encoding: JSONEncoding.default, headers: ["Authorization": token ?? "No value"])
        } else {
            request = AF.request(router.url, method: .post, parameters: router.parameters, encoding: JSONEncoding.default, headers: nil)
        }
        
        request.responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    func put<T: Codable> (completion: @escaping Completion<T>) {
        let request = AF.request(router.url, method: .put, parameters: router.parameters, encoding: JSONEncoding.default, headers: ["Authorization": token ?? "No value"])
        
        request.responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    func delete<T: Codable> (completion: @escaping Completion<T>) {
        let request = AF.request(router.url, method: .delete, parameters: router.parameters, encoding: JSONEncoding.default, headers: ["Authorization": token ?? "No value"])
        
        request.responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
}
