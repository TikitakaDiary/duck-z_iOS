//
//  BookListViewModel.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/06/29.
//

import Foundation
import RxSwift

class HomeViewModel {
    let bookStorage: BookStorageType
    let profileStorage: ProfileStorage
    let isReceivedFCM = BehaviorSubject<Bool>(value: false)
    
    init (bookStorage: BookStorageType, profileStorage: ProfileStorage) {
        self.bookStorage = bookStorage
        self.profileStorage = profileStorage
    }
    
    var userProfile: Observable<Profile> {
        return profileStorage.userProfile()
    }
    
    var bookList: Observable<[Book]> {
        return bookStorage.bookList()
    }
    
    func bookListCount() -> Int {
        return bookStorage.bookListCount()
    }
    
    func isFetchingAvailable() -> Bool {
        return bookStorage.isFetchingAvailable()
    }
 
    func fetch(indexPath: IndexPath) {
        if self.bookStorage.isFetchingAvailable() && indexPath.item == self.bookStorage.bookListCount() - 10  {
            bookStorage.fetchBooks()
        }
    }
    
    func refresh() {
        bookStorage.refreshBooks()
    }
}
