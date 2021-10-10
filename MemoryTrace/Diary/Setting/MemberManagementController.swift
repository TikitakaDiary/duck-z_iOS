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

    var viewModel = MemberManagementViewModel(bookId: CurrentBook.shared.book?.bid)
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = self.view.frame.width * 0.16
        inviteButton.layer.cornerRadius = 20
        bind()
    }
    
    private func bind() {
        self.viewModel.members()
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: "MemberCell", cellType: MemberCell.self)) { [weak self] index, item, cell in
                if self?.viewModel.whoseTurn() == item.uid {
                    cell.view.addBorder(borderWidth: 2, borderColor: UIColor(red: 246/255, green: 206/255, blue: 41/255, alpha: 1))
                    cell.writingStateLabel.isHidden = false
                }
                cell.nameLabel.text = item.nickname
            }
            .disposed(by: disposeBag)
        
        self.viewModel.errorMessage
            .subscribe { [weak self] errMessage in
                self?.showToast(message: errMessage, position: .bottom)
            }
            .disposed(by: disposeBag)
        
        self.inviteButton.rx.tap
            .bind { [unowned self] _ in
                if self.viewModel.code().isEmpty {
                    self.showToast(message: "코드 생성에 실패했습니다.", position: .bottom)
                } else {
                    self.showToast(message: "코드가 복사되었습니다.", position: .bottom)
                    UIPasteboard.general.string = self.viewModel.code()
                }
            }
            .disposed(by: disposeBag)
    }
}

