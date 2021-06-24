//
//  MemberManagementController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/19.
//

import UIKit
import RxSwift
import RxCocoa

class MemberManagementController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inviteButton: UIButton!

    var viewModel: MemberManagementViewModel!
    let disposeBag = DisposeBag()
    lazy private var invitationCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = self.view.frame.width * 0.16
        inviteButton.layer.cornerRadius = 20
        
        guard let bid = CurrentBook.shared.book?.bid else { return }
        self.viewModel = MemberManagementViewModel(bid:bid)

        self.viewModel.members
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: "MemberCell", cellType: MemberCell.self)) { index, item, cell in
                cell.nameLabel.text = item.nickname
            }
            .disposed(by: disposeBag)
        
        self.viewModel.invitationCode
            .subscribe(onNext: { self.invitationCode = $0 })
            .disposed(by: disposeBag)
    }
    
    @IBAction func didPressInviteButton(_ sender: UIButton) {
        if invitationCode.isEmpty {
            showToast(message: "코드 생성에 실패했습니다.", position: .bottom)
        } else {
            showToast(message: "코드가 복사되었습니다.", position: .bottom)
            UIPasteboard.general.string = invitationCode
        }
    }
}

