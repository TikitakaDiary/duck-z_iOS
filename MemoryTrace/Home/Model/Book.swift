//
//  Book.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/12.
//

import UIKit

// MARK: - 일기장 생성 & 조회
struct BookInfo: Codable {
    let statusCode: Int
    let responseMessage: String
    let data: BookDetail
}

struct BookDetail: Codable {
    let bid: Int
    let whoseTurn: Int?
    let inviteCode: String?
    let createdDate: String?
    let userList: [User]?
}

struct User: Codable {
    let uid: Int
    let nickname: String
    let profileImg: String?
}

// MARK: - 일기장 리스트 조회
class CurrentBook {
    static let shared = CurrentBook()
    private init() {}
    var book: Book? = nil
//    var cellIdx: Int? = nil
}

class Books {
    var currentPage: Int = 1
    var nextPage: Int = 1
    var hasNext: Bool = false
    var showingbooks: [Book] = []
}

struct BookList: Codable {
    let statusCode: Int
    let responseMessage: String
    let data: BookListData
}

struct BookListData: Codable {
    let curPage: Int
    let hasNext: Bool
    let bookList: [Book]
}

struct Book: Codable {
    let bid: Int
    let nickname: String
    let title: String
    let bgColor: Int
    let stickerImg: String?
    let modifiedDate: String
}

// MARK: - 일기장 Cover
struct BookCover {
    let bgColor: Int
    let title: String
    let stickerImage: UIImage?
    let bid: Int?
    
    init(bgColor: Int, title: String, stickerImage: UIImage?, bid: Int? = nil) {
        self.bgColor = bgColor
        self.title = title
        self.stickerImage = stickerImage
        self.bid = bid
    }
}

struct NoDataResponse: Codable {
    let statusCode: Int
    let responseMessage: String
}


