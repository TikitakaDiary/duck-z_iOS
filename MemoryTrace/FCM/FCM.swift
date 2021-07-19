//
//  FCM.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/07/06.
//

import Foundation

struct FCM: Codable {
    let statusCode: Int
    let responseMessage: String
    let data: Token?
}

struct Token: Codable {
    let uid: Int
    let token: String
}
