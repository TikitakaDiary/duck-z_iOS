//
//  DiaryDetailViewModel.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/07/16.
//

import Foundation
import RxSwift

class DiaryDetailViewModel {
    private let disposeBag = DisposeBag()
    private var store: BehaviorSubject<Content>!
    private var error = PublishSubject<Error>()
    
    init(diaryDetail: Content) {
        self.store = BehaviorSubject<Content>(value: diaryDetail)
        fetch(diaryID: diaryDetail.did)
    }
    
    func fetch(diaryID: Int) {
        NetworkManager.shared.fetchDiaryRx(diaryID: diaryID)
            .take(1)
            .subscribe(onNext: { [weak self] content in
                self?.store.onNext(content)
            }, onError: { [weak self] err in
                self?.error.onNext(err)
            })
            .disposed(by: disposeBag)
    }
    
    func content() -> Observable<Content> {
        return store.asObservable()
    }
    
    func errorMessage() -> Observable<String> {
        return error.compactMap { $0.localizedDescription }
    }
    
    func isWriter() -> Bool {
        return true
    }
    
    func isEditAvailable() -> Bool {
        return true
    }
}
