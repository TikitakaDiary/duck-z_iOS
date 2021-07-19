//
//  BookStorageType.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/07/13.
//

import Foundation
import RxSwift

protocol BookStorageType {
    func fetchBooks() -> Void
    func refreshBooks() -> Void
    func bookListCount() -> Int
    func isFetchingAvailable() -> Bool
    
    @discardableResult
    func bookList() -> Observable<[Book]>
}
