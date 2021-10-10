//
//  NameStorage.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/07/13.
//

import Foundation
import RxSwift

class ProfileStorage {
    let disposeBag = DisposeBag()
    
    private lazy var store = BehaviorSubject<Profile>(value: Profile(nickname: "", snsType: "", createdDate: ""))
    
    func userProfile() -> Observable<Profile> {
        return store
    }
    
    init() {
        fetchProfile()
    }
    
    func fetchProfile() {
        if let name = UserManager.name, let snsType = UserManager.snsType, let signInDate = UserManager.signInDate {
            let profile = Profile(nickname: name, snsType: snsType, createdDate: signInDate)
            store.onNext(profile)
        } else {
            NetworkManager.shared.fetchUserInfoRx()
                .take(1)
                .compactMap { $0.data }
                .subscribe(with: self, onNext: { (owner, userData) in
                    UserManager.snsType = userData.snsType
                    UserManager.signInDate = userData.createdDate.date(type: .yearMonthDay)
                    UserManager.name = userData.nickname
                    let profile = Profile(nickname: userData.nickname, snsType: userData.snsType, createdDate: userData.createdDate.date(type: .yearMonthDay))
                    owner.store.onNext(profile)
                })
                .disposed(by: disposeBag)
        }
    }
}
