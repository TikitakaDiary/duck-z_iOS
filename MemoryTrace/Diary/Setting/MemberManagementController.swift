//
//  MemberManagementController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/19.
//

import UIKit

class MemberManagementController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inviteButton: UIButton!
    
    private var userList: [User] = []
    lazy private var inviteCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.rowHeight = 80
        inviteButton.layer.cornerRadius = 22
        
        guard let bid = CurrentBook.shared.book?.bid else { return }

        NetworkManager.shared.fetchBookInfo(bookID: bid) { [weak self] (result) in
            switch result {
            case .success(let bookInfo):
                guard let inviteCode = bookInfo.data.inviteCode, let userList = bookInfo.data.userList else {return}
    
                self?.inviteCode = inviteCode
                self?.userList = userList
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.showToast(message: error.localizedDescription, position: .bottom)
            }
        }
    }
    
    @IBAction func didPressInviteButton(_ sender: UIButton) {
        if inviteCode.isEmpty {
            showToast(message: "코드 생성에 실패했습니다.", position: .bottom)
        } else {
            showToast(message: "코드가 복사되었습니다.", position: .bottom)
            UIPasteboard.general.string = inviteCode
        }
    }
}

extension MemberManagementController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
        
        cell.nameLabel.text = userList[indexPath.row].nickname
        return cell
    }
}
