//
//  NetworkManager.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/10.
//
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    typealias Completion<T> = (Result<T, Error>) -> Void
    
    private init() {}
    
    func login(login: Login, completion: @escaping Completion<LoginResponse>) {
        let router: Router = .login(login: login)
        APIRequester(with: router).postRequest(completion: completion)
    }
    
    func fetchUserInfo(completion: @escaping Completion<LoginResponse>) {
        let router: Router = .fetchUserInfo
        APIRequester(with: router).getRequest(completion: completion)
    }
    
    func createBook(bookCover: BookCover, completion: @escaping Completion<BookInfo>) {
        let router: Router = .createBook(bookCover: bookCover)
        let imageData = bookCover.stickerImage?.pngData()
        APIRequester(with: router).postMultiPartRequest(imageName: "stickerImg", data: imageData, completion: completion)
    }
    
    func fetchBookInfo(bookID: Int, completion: @escaping Completion<BookInfo>) {
        let router: Router = .fetchBookInfo(bookID: bookID)
        APIRequester(with: router).getRequest(completion: completion)
    }
    
    func fetchBookList(page: Int, completion: @escaping Completion<BookList>) {
        let router: Router = .fetchBookList(page: page)
        APIRequester(with: router).getRequest(completion: completion)
    }
    
    func createDiary(writingContent: WritingContent, completion: @escaping Completion<Diary>) {
        let router: Router = .createDiary(writingContent: writingContent)
        let imageData = writingContent.image.jpegData(compressionQuality: 0.5)
        APIRequester(with: router).postMultiPartRequest(imageName: "img", data: imageData, completion: completion)
    }
    
    func fetchDiary(diaryID: Int, completion: @escaping Completion<DiaryContent>) {
        let router: Router = .fetchDiary(diaryID: diaryID)
        APIRequester(with: router).getRequest(completion: completion)
    }
    
    func fetchDiaryList(bookID: Int, page: Int, size: Int, completion: @escaping Completion<DiaryList>) {
        let router: Router = .fetchDiaryList(bookID: bookID, page: page, size: size)
        APIRequester(with: router).getRequest(completion: completion)
    }
    
    func modifyName(name: String, completion: @escaping Completion<LoginResponse>) {
        let router: Router = .modifyName(name: name)
        APIRequester(with: router).put(completion: completion)
    }
    
    func deleteAccount(completion: @escaping Completion<LoginResponse>) {
        let router: Router = .deleteAccount
        APIRequester(with: router).getRequest(completion: completion)
    }
    
    func exitBook(bookID: Int, completion: @escaping Completion<NoDataResponse>) {
        let router: Router = .exitBook(bookID: bookID)
        APIRequester(with: router).put(completion: completion)
    }
    
    func modifyBookCover(bookCover: ModifiedBookCover, completion: @escaping    Completion<NoDataResponse>) {
        let router: Router = .modifyBookCover(bookCover: bookCover)
        let imageData = bookCover.stickerImage?.pngData()
        APIRequester(with: router).postMultiPartRequest(imageName: "stickerImg", data: imageData, completion: completion)
    }
    
    func enterDiary(invitationCode: String, completion: @escaping    Completion<NoDataResponse>) {
        let router: Router = .invite(invitationCode: invitationCode)
        APIRequester(with: router).postRequest(completion: completion)
    }
}

