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
    private var store = BehaviorSubject<Content?>(value: nil)
    
    init(diaryID: Int) {
        fetch(diaryID: diaryID)
    }
    
    func fetch(diaryID: Int) {
        NetworkManager.shared.fetchDiaryRx(diaryID: diaryID)
            .take(1)
            .subscribe { [weak self] content in
                self?.store.onNext(content)
            }
            .disposed(by: disposeBag)
    }
    
    func content() -> Observable<Content?> {
        return store.asObservable()
    }
    
    func isWriter() -> Bool {
        return true
    }
    
    func isEditAvailable() -> Bool {
        return true
    }
}
