//
//  HomeViewModel2.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/10/05.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    
    var disposeBag = DisposeBag()
    let profileStorage: ProfileStorage
    var isFetching: Bool = false
    var hasNext: Bool = true
    
    // Input
    let currentPage = BehaviorRelay<Int>(value: 1)
    let pullToRefresh = BehaviorRelay<Void>(value: ())
    let isReceivedFCM = BehaviorRelay<Bool>(value: false)
    
    // output
    let bookList = BehaviorRelay<[Book]>(value: [])
    let noBooksLabelIsHidden = PublishRelay<Bool>()
    let error = PublishRelay<NetworkError>()
    
    init(profileStorage: ProfileStorage) {
        self.profileStorage = profileStorage
        bind()
    }
    
    private func bind() {
        pullToRefresh.asObservable()
            .subscribe { [weak self] _ in
                self?.currentPage.accept(1)
            }
            .disposed(by: disposeBag)
        
        currentPage.asObservable()
            .flatMapLatest { [weak self] (page: Int) -> Observable<[Book]> in
                self?.fetchBooks(page: page) ?? Observable.just([])
            }
            .subscribe(onNext: { [weak self] books in
                self?.bookList.accept((self?.currentPage.value == 1 ? [] : (self?.bookList.value ?? [])) + books)
            }, onError: { [weak self] error in
                self?.error.accept(.unknown)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchBooks(page:Int = 1) -> Observable<[Book]> {
        isFetching = true
        let result = NetworkManager.shared.fetchBookListRx(page: page)
        
        return Observable.create { emitter in
            result
                .subscribe(onNext: { [weak self] books in
                    if books.data.curPage == 1 && books.data.bookList.count == 0 {
                        self?.noBooksLabelIsHidden.accept(false)
                    } else {
                        self?.noBooksLabelIsHidden.accept(true)
                    }
                    self?.hasNext = books.data.hasNext
                    self?.isFetching = false
                    emitter.onNext(books.data.bookList)
                    emitter.onCompleted()
                }, onError: { [weak self] error in
                    self?.bookList.accept([])
                    self?.error.accept(.network)
                    self?.noBooksLabelIsHidden.accept(false)
                    self?.isFetching = false
                })
        }
    }
    
    var userProfile: Observable<Profile> {
        return profileStorage.userProfile()
    }
}

