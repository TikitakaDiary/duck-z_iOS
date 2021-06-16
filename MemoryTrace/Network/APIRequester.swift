//
//  APIRequester.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/12.
//

import Alamofire

struct APIRequester {
    typealias Completion<T> = (Result<T, Error>) -> Void
    
    let router: Router
    private let token = "NULL"
    
    init(with router: Router) {
        self.router = router
    }
    
    func getRequest<T: Codable> (completion: @escaping Completion<T>) {
        let request = AF.request(router.url, method: .get, headers: ["Authorization": token ?? "No value"]
        )
        
        request.responseDecodable(of: T.self) { response in
            switch response.result {
            case let .success(result):
                completion(.success(result))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func postMultiPartRequest<T: Codable> (imageName: String, data: Data? = nil, completion: @escaping Completion<T>) {
        AF.upload(multipartFormData: { multiPart in
            if data != nil {
                multiPart.append(data!, withName: imageName, fileName: "image.png", mimeType: "image/png")
            }
            for (key, value) in router.parameters {
                multiPart.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: router.url, method: .post, headers: ["Authorization": token ?? "No value"]).responseJSON(completionHandler: { data in
        }).responseDecodable(of: T.self) { response in
            switch response.result {
            case let .success(result):
                completion(.success(result))
            case let .failure(error):
                completion(.failure(error))
            }
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
            switch response.result {
            case let .success(result):
                completion(.success(result))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func put<T: Codable> (completion: @escaping Completion<T>) {
        let request = AF.request(router.url, method: .put, parameters: router.parameters, encoding: JSONEncoding.default, headers: ["Authorization": token ?? "No value"])
        
        request.responseDecodable(of: T.self) { response in
            switch response.result {
            case let .success(result):
                completion(.success(result))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
