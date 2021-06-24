//
//  MemberManagementViewModel.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/06/24.
//

import Foundation
import RxSwift
import RxRelay

class MemberManagementViewModel {
    let bookInfo = PublishSubject<BookInfo>()

    lazy var members = bookInfo.compactMap {
        $0.data.userList
    }
    
    lazy var invitationCode = bookInfo.compactMap {
        $0.data.inviteCode
    }

    init(bid: Int) {
        _ = NetworkManager.shared.fetchBookInfoRx(bookID: bid)
            .take(1)
            .bind(to: bookInfo)
    }
}
