//
//  BookStorage.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/07/13.
//

import Foundation
import RxSwift

class BookStorage: BookStorageType {
    
    private let disposeBag = DisposeBag()
    private var list: [Book] = []
    private var page: Int = 1
    private var isFetching: Bool = false
    var hasNext: Bool = false
    private lazy var store = BehaviorSubject<[Book]>(value: list)

    let fetching = BehaviorSubject<Bool>(value: false)
    
    init() {
        fetchBooks()
    }
    
    func fetchBooks() {
        guard isFetching == false else { return }
        self.isFetching = true
        NetworkManager.shared.fetchBookListRx(page: page)
            .take(1)
            .do { [weak self] books in
                self?.list.append(contentsOf: books.data.bookList)
                self?.page = books.data.curPage + 1
                self?.hasNext = books.data.hasNext
            }
            .subscribe { [unowned self] _ in
                self.store.onNext(self.list)
                self.isFetching = false
            }
            .disposed(by: disposeBag)
    }
    
    func refreshBooks() {
        self.list.removeAll()
        self.page = 1
        fetchBooks()
    }
    
    func bookList() -> Observable<[Book]> {
        return store
    }
    
    func bookListCount() -> Int {
        return list.count
    }
    
    func isFetchingAvailable() -> Bool {
        return hasNext
    }
}
