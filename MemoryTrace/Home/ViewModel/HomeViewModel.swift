//
//  HomeViewModel.swift
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
            .subscribe(with: self) { (owner, _) in
                owner.currentPage.accept(1)
            }
            .disposed(by: disposeBag)

        currentPage.asObservable()
            .withUnretained(self)
            .flatMapLatest { (owner, page) in
                owner.fetchBooks(page: page)
            }
            .subscribe(with: self, onNext: { (owner, books) in
                owner.bookList.accept((owner.currentPage.value == 1 ? [] : (owner.bookList.value)) + books)
            }, onError: { (owner, error) in
                owner.error.accept(.unknown)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchBooks(page:Int = 1) -> Observable<[Book]> {
        isFetching = true
        let result = NetworkManager.shared.fetchBookListRx(page: page)
        
        return Observable.create { emitter in
            result
                .subscribe(with: self, onNext: { (owner, books) in
                    if books.data.curPage == 1 && books.data.bookList.count == 0 {
                        owner.noBooksLabelIsHidden.accept(false)
                    } else {
                        owner.noBooksLabelIsHidden.accept(true)
                    }
                    owner.hasNext = books.data.hasNext
                    owner.isFetching = false
                    emitter.onNext(books.data.bookList)
                    emitter.onCompleted()
                }, onError: { (owner, error) in
                    owner.bookList.accept([])
                    owner.error.accept(.network)
                    owner.noBooksLabelIsHidden.accept(false)
                    owner.isFetching = false
                })
        }
    }
    
    var userProfile: Observable<Profile> {
        return profileStorage.userProfile()
    }
}
