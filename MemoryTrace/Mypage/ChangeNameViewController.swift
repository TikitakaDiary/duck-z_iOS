//
//  ChangeNameViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/22.
//

import UIKit

class ChangeNameViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    var profileStorage: ProfileStorage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setupUI() {
        self.nameTextField.text = UserManager.name
        
        let saveButton = UIButton()
        saveButton.setTitle("저장", for: .normal)
        saveButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 9)
        saveButton.frame.size.width = 50
        saveButton.contentHorizontalAlignment = .right
        saveButton.addTarget(self, action: #selector(didPressSave), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
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

                UserManager.name = modifiedName
                
                self?.profileStorage.fetchProfile()
                
                NotificationCenter.default.post(name: NSNotification.Name("updateBooks"), object: BookUpdateType.update)
                self?.navigationController?.popViewController(animated: true)
            case .failure(let error):
                self?.view.endEditing(true)
                self?.showToast(message: error.localizedDescription, position: .bottom)
            }
        }
    }
}
