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
        if let name = UserDefaults.standard.string(forKey: "name"), let snsType = UserDefaults.standard.string(forKey: "snsType"), let signInDate = UserDefaults.standard.string(forKey: "signInDate") {
            let profile = Profile(nickname: name, snsType: snsType, createdDate: signInDate)
            store.onNext(profile)
        } else {
            NetworkManager.shared.fetchUserInfoRx()
                .take(1)
                .compactMap { $0.data }
                .do(onNext: { userData in
                    UserDefaults.standard.setValue(userData.snsType, forKey: "snsType")
                    UserDefaults.standard.setValue(userData.createdDate.date(type: .yearMonthDay), forKey: "signInDate")
                    UserDefaults.standard.setValue(userData.nickname, forKey: "name")
                })
                .bind { userData in
                    let profile = Profile(nickname: userData.nickname, snsType: userData.snsType, createdDate: userData.createdDate.date(type: .yearMonthDay))
                    self.store.onNext(profile)
                }
                .disposed(by: disposeBag)
        }
    }
}
