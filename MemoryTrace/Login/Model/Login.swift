//
//  User.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/18.
//

import Foundation

struct Login: Codable {
    let profileImg: String?
    let nickname: String
    let snsKey: String
    let snsType: SNSType
    let token:  String
}

struct LoginResponse: Codable {
    let statusCode: Int
    let responseMessage: String
    let data: UserData?
}

struct UserData: Codable {
    let uid: Int
    let nickname: String
    let snsType: String
    let profileImg: String?
    let createdDate: String
    let jwt: String
}

struct Profile {
    let nickname: String
    let snsType: String
    let createdDate: String
}


