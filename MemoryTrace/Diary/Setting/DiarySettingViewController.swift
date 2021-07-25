//
//  DiarySettingViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/09.
//

import UIKit

class DiarySettingViewController: UIViewController {
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "일기 설정"
        self.view.backgroundColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)
        
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Apple SD Gothic Neo", size: 16) ?? UIFont.systemFont(ofSize: 16)]
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.rowHeight = 50
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
    }
}

extension DiarySettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "멤버 관리"
            let image = UIImage(named: "disclosure")
            cell.accessoryView = UIImageView(image: image)
        }
        else if indexPath.row == 1 {
            cell.textLabel?.text = "일기장 표지 수정"
            let image = UIImage(named: "disclosure")
            cell.accessoryView = UIImageView(image: image)
        }
        else {
            cell.textLabel?.text = "일기장 나가기"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard let memberVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MemberManagementVC") as? MemberManagementController else { return }
            
            self.navigationController?.pushViewController(memberVC, animated: true)
        }
        else if indexPath.row == 1 {
            guard let decoratingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DecoratingVC") as? DecoratingViewController else { return }
            decoratingVC.editType = .modify
            decoratingVC.modalPresentationStyle = .fullScreen
            self.present(decoratingVC, animated: true, completion: nil)
        }
        else {
            let exitAction = UIAlertAction(title: "나가기", style: .destructive) { _ in
                guard let bid = CurrentBook.shared.book?.bid else { return }
                
                NetworkManager.shared.exitBook(bookID: bid) { response in
                    self.navigationController?.popToRootViewController(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name("updateBooks"), object: BookUpdateType.delete)
                }
            }
            showAlert(title: "일기장을 나가시겠어요?", message: "일기장을 나갈 시, 작성했던 일기장에 접근할 수 없습니다. 그래도 나가시겠습니까?", action: exitAction)
        }
    }
}
