//
//  Comment.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/09/21.
//

import Foundation

struct Reply {
    let content: String
    let did: Int
    let parent: Int
}

struct Comment {
    let content: String
    let did: Int
}

struct CommentResponse: Codable {
    let statusCode: Int
    let responseMessage: String
    let data: CommentID?
}

struct CommentID: Codable {
    let cid: Int
}

struct CommentListResponse: Codable {
    let statusCode: Int
    let responseMessage: String
    let data: [CommentInfo]
}

struct CommentInfo: Codable {
    let cid: Int
    let uid: Int
    let nickname: String
    var content: String
    let createdDate: String
    var isDelete: Int
    var commentList: [CommentInfo]?
}

