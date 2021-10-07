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
    case modifyBookCover(bookCover: BookCover)
    case exitBook(bookID: Int)
    case postFCMToken(uid: Int, token: String)
    case deleteFCMToken(uid: Int, fcmToken: String)
    case fcmTest(uid: Int, fcmToken: String)
    case modifyDiary(modifiedContent: ModifiedContent)
    case comment(commentInfo: Comment)
    case reply(replyInfo: Reply)
    case deleteComment(commentID: Int)
    case fetchCommentList(diaryID: Int)
    
    private var baseURL: String {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String
        return baseURL ?? "invalidURL"
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
            return "/book/list?page=\(page)&size=10"
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
        case .postFCMToken:
            return "/user/fcm"
        case .deleteFCMToken:
            return "/token"
        case .fcmTest:
            return "/token/test"
        case .modifyDiary:
            return "/diary/update"
        case .comment:
            return "/comment"
        case .reply:
            return "/comment"
        case .deleteComment(let commentID):
            return "/comment/\(commentID)"
        case .fetchCommentList(let diaryID):
            return "/comment/list/\(diaryID)"
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
            return ["nickname" : login.nickname, "snsKey" : login.snsKey, "snsType" : login.snsType.rawValue, "token" : login.token]
        case .fetchUserInfo:
            return [:]
        case .modifyName(let name):
            return ["nickname": name]
        case .deleteAccount:
            return [:]
        case .modifyBookCover(let bookCover):
            return ["bgColor": bookCover.bgColor, "title": bookCover.title, "bid" : bookCover.bid!]
        case .exitBook:
            return [:]
        case .postFCMToken(let uid, let token):
            return ["token":token, "uid": uid]
        case .deleteFCMToken(let uid, let token):
            return ["uid" : uid, "token" : token]
        case .fcmTest(let uid, let token):
            return ["uid" : uid, "token" : token]
        case .modifyDiary(let modifiedContent):
            return ["did" : modifiedContent.diaryID, "content" : modifiedContent.content, "title" : modifiedContent.title]
        case .comment(let comment):
            return ["content" : comment.content, "did" : comment.did]
        case .reply(let reply):
            return ["content" : reply.content, "did" : reply.did, "parent" : reply.parent]
        case .deleteComment:
            return [:]
        case .fetchCommentList:
            return [:]
        }
    }
}
