//
//  Diary.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/12.
//

import UIKit

// MARK: - 다이어리 생성
struct Diary: Codable {
    let statusCode: Int
    let responseMessage: String
    let data: DiaryID
}

struct DiaryID: Codable {
    let did: Int
}

// MARK: - 다이어리 조회
struct DiaryContent: Codable {
    let statusCode: Int
    let responseMessage: String
    let data: Content
}

struct Content: Codable {
    let modifiable: Bool
    let uid: Int
    let did: Int
    let nickname: String
    let title: String
    let img: String
    let content: String
    let template: Int
    let createdDate: String
}

// MARK: - 다이어리 리스트 조회
struct DiaryList: Codable {
    let statusCode: Int
    let responseMessage: String
    let data: DiaryListData
}

struct DiaryListData: Codable {
    let curPage: Int
    let hasNext: Bool
    let title: String
    let whoseTurn: Int
    let diaryList: [DiaryInfo]
}

struct DiaryInfo: Codable {
    let did: Int
    let nickname: String
    let title: String
    let img: String
    let template: Int
    let createdDate: String
}

// MARK: - 일기
struct WritingContent {
    let bookID: Int
    let title: String
    let content: String
    let image: UIImage
}

struct ModifiedContent {
    let diaryID: Int
    let title: String
    let content: String
    let image: UIImage?
}
