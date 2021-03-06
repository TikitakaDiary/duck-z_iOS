//
//  MypageViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/22.
//

import UIKit
import RxSwift

class MypageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var completionButton: UIButton!
    @IBOutlet weak var inviteTextField: UITextField!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var socialLabel: UILabel!
    @IBOutlet weak var createDateLabel: UILabel!
    
    var profileStorage: ProfileStorage!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        userInfoView.layer.cornerRadius = 8
        completionButton.layer.cornerRadius = completionButton.frame.width * 0.235

        toolbarSetup(textField: inviteTextField)
        
        profileStorage.userProfile()
            .bind { profile in
                self.nameLabel.text = profile.nickname
                self.socialLabel.text = profile.snsType
                self.createDateLabel.text = profile.createdDate
            }
            .disposed(by: disposeBag)
    }

    @IBAction func didPressEditButton(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangeNameVC") as? ChangeNameViewController else {return}
        
        vc.profileStorage = self.profileStorage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didPressCompleteButton(_ sender: UIButton) {
        inviteTextField.endEditing(true)
     
        guard let code = inviteTextField.text, !code.getArrayAfterRegex(regex: "[^\\s]").isEmpty else {
            showToast(message: "초대 코드를 입력해주세요!", position: .bottom)
            return }
        
        NetworkManager.shared.enterDiary(invitationCode: code) { [weak self] (result) in
            switch result {
            case .success(let response):
                if 200 <= response.statusCode && response.statusCode < 300 {
                    self?.inviteTextField.text = nil
                    NotificationCenter.default.post(name: NSNotification.Name("updateBooks"), object: BookUpdateType.add)
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.showToast(message: response.responseMessage, position: .bottom)
                }
            case .failure(_):
                self?.showToast(message: "error: fail", position: .bottom)
            }
        }
    }
    
    @IBAction func didPressDeleteAccountButton(_ sender: UIButton) {
        let deleteAction = UIAlertAction(title: "탈퇴하기", style: .destructive) { _ in
            NetworkManager.shared.deleteAccount { [weak self] (result) in
                switch result {
                case .success(_):
                    self?.removeUserData()
                    self?.moveToLoginViewController()
                case .failure(let error):
                    self?.showToast(message: error.localizedDescription, position: .bottom)
                }
            }
        }
        
        showAlert(title: "회원탈퇴", message: "회원탈퇴시, 저장한 정보는 삭제됩니다.", action: deleteAction)
    }
    
    private func signout() {
        if let fcmToken = UserManager.fcmToken {
            let uid = UserManager.uid
            
            NetworkManager.shared.deleteFCMToken(uid: uid, token: fcmToken) { [weak self] result in
                switch result {
                case .success(_):
                    self?.removeUserData()
                    self?.moveToLoginViewController()
                case .failure(let err):
                    self?.showToast(message: err.localizedDescription, position: .bottom)
                }
            }
        }
    }
    
    private func removeUserData() {
        UserManager.jwt = nil
        UserManager.name = nil
        UserManager.uid = 0
        UserManager.snsType = nil
        UserManager.signInDate = nil
    }
    
    private func moveToLoginViewController() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow?.rootViewController = vc
        self.navigationController?.viewControllers.removeAll()
    }
}

extension MypageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .default
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        switch indexPath.row {
        case 0:
            cell.textLabel?.textColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
            cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
            cell.textLabel?.text = "서비스 정보"
            cell.selectionStyle = .none
        case 1:
            cell.textLabel?.text = "앱 현재 버전"
            cell.selectionStyle = .none
            let versionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 25))
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            versionLabel.text = appVersion
            versionLabel.textAlignment = .right
            versionLabel.textColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            versionLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
            cell.accessoryView = versionLabel
        case 2:
            cell.textLabel?.text = "만든 사람들"
            cell.accessoryView = UIImageView(image: UIImage(named: "disclosure"))
        case 3:
            cell.textLabel?.text = "Open Source License"
            cell.accessoryView = UIImageView(image: UIImage(named: "disclosure"))
        case 4:
            cell.textLabel?.textColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
            cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
            cell.textLabel?.text = "사용자 지원"
            cell.selectionStyle = .none
        case 5:
            cell.textLabel?.text = "문의하기"
            cell.accessoryView = UIImageView(image: UIImage(named: "disclosure"))
        case 6:
            cell.textLabel?.text = "로그아웃"
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let makersVC = MakersViewController()
            self.navigationController?.pushViewController(makersVC, animated: true)
        } else if indexPath.row == 3 {
            guard let licenseVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LicenseVC") as? LicenseViewController else { return }
            self.navigationController?.pushViewController(licenseVC, animated: true)
        } else if indexPath.row == 5 {
            guard let url = URL(string: "mailto:" + "help.duck.z@gmail.com") else { return }
            UIApplication.shared.open(url)
        } else if indexPath.row == 6 {
            let logoutAction = UIAlertAction(title: "로그아웃", style: .destructive) { _ in
                self.signout()
            }
            showAlert(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", action: logoutAction)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
