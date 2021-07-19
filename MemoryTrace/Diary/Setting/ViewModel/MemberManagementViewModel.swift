//
//  MemberManagementViewModel.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/06/24.
//

import Foundation
import RxSwift

class MemberManagementViewModel {
    let disposeBag = DisposeBag()
    
    private var invitationCode = ""
    private var turn = 0
    private var error = PublishSubject<Error>()
    private var userList = BehaviorSubject<[User]>(value: [])
    
    lazy var errorMessage = error.compactMap {
        $0.localizedDescription
    }
    
    init(bookId: Int?) {
        guard let bid = bookId else { return }
        
        NetworkManager.shared.fetchBookInfoRx(bookID: bid)
            .take(1)
            .do(onNext: { [weak self] info in
                self?.invitationCode = info.data.inviteCode ?? ""
                self?.turn = info.data.whoseTurn ?? 0
            })
            .subscribe(onNext: { [weak self] info in
                self?.userList.onNext(info.data.userList ?? [])
            }, onError: { [weak self] err in
                self?.error.onNext(err)
            })
            .disposed(by: disposeBag)
    }
    
    func members() -> Observable<[User]> {
        return userList
    }
    
    func code() -> String {
        return self.invitationCode
    }
    
    func whoseTurn() -> Int {
        return self.turn
    }
}
