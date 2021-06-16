//
//  Router.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/11.
//

import Foundation

enum Router {
    case createBook(bookCover: BookCover)
    case fetchBookInfo(bookID: Int)
    case fetchBookList(page: Int)
    case createDiary(writingContent: WritingContent)
    case fetchDiary(diaryID: Int)
    case fetchDiaryList(bookID: Int, page: Int, size: Int)
    case invite(invitationCode: String)
    case login(login: Login)
    case fetchUserInfo
    case modifyName(name: String)
    case deleteAccount
    case modifyBookCover(bookCover: ModifiedBookCover)
    case exitBook(bookID: Int)
    
    private var baseURL: String {
        return ""
    }
    
    var url: String {
        return baseURL + path
    }
    
    private var path: String {
        switch self {
        case .createBook:
            return "/book"
        case .fetchBookInfo(let id):
            return "/book/\(id)"
        case .fetchBookList(let page):
            return "/book/list?page=\(page)&size=20"
        case .createDiary:
            return "/diary"
        case .fetchDiary(let diaryID):
            return "/diary/\(diaryID)"
        case .fetchDiaryList(let bookID, let page, let size):
            return "/diary/list/\(bookID)?page=\(page)&size=\(size)"
        case .invite:
            return "/invite"
        case .login:
            return "/user"
        case .fetchUserInfo:
            return "/user"
        case .modifyName:
            return "/user"
        case .deleteAccount:
            return "/user/withdrawal"
        case .modifyBookCover:
            return "/book/update"
        case .exitBook(let bookID):
            return "/book/exit/\(bookID)"
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .createBook(let bookCover):
            return ["bgColor": bookCover.bgColor, "title": bookCover.title]
        case .createDiary(let writingContent):
            return ["bid" : writingContent.bookID, "content" : writingContent.content, "img" : writingContent.image, "title" : writingContent.title]
        case .fetchBookInfo:
            return [:]
        case .fetchBookList:
            return [:]
        case .fetchDiary:
            return [:]
        case .fetchDiaryList:
            return [:]
        case .invite(let code):
            return ["inviteCode": code]
        case .login(let login):
            return ["nickname" : login.nickname, "snsKey" : login.snsKey, "snsType" : login.snsType.rawValue]
        case .fetchUserInfo:
            return [:]
        case .modifyName(let name):
            return ["nickname": name]
        case .deleteAccount:
            return [:]
        case .modifyBookCover(let bookCover):
            return ["bgColor": bookCover.bgColor, "title": bookCover.title, "bid" : bookCover.bid]
        case .exitBook:
            return [:]
        }
    }
}
