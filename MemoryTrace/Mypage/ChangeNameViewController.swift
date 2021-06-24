//
//  ChangeNameViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/22.
//

import UIKit

class ChangeNameViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.text = UserDefaults.standard.string(forKey: "name")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(didPressSave))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func didPressSave() {
        guard let nameText = nameTextField.text, !nameText.getArrayAfterRegex(regex: "[^\\s]").isEmpty else {
            showToast(message: "이름을 입력해주세요", position: .center)
            return}

        NetworkManager.shared.modifyName(name: nameText) { [weak self] (result) in
            switch result {
            case .success(let response):
                guard let data = response.data else {return}
                let modifiedName = data.nickname
                UserDefaults.standard.setValue(modifiedName, forKey: "name")
                guard let postVC = self?.navigationController?.viewControllers[1] as? MypageViewController else {return}
                
                postVC.nameLabel.text = modifiedName
                NotificationCenter.default.post(name: NSNotification.Name("updateBooks"), object: BookUpdateType.update)
                self?.navigationController?.popViewController(animated: true)
            case .failure(let error):
                self?.view.endEditing(true)
                self?.showToast(message: error.localizedDescription, position: .bottom)
            }
        }
    }
}
