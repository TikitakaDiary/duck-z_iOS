////
////  ReadingViewController.swift
////  MemoryTrace
////
////  Created by seunghwan Lee on 2021/06/01.
////
//
//import UIKit
//import Kingfisher
//
//class ReadingViewController: UIViewController {
//    
//    @IBOutlet weak var polaroidView: UIView!
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var titleTextField: UITextField!
//    @IBOutlet weak var dateLabel: UILabel!
//    @IBOutlet weak var writerLabel: UILabel!
//    @IBOutlet weak var textView: UITextView!
//    
//    var did: Int? = nil
//    var uid: Int? = nil
//    var createdDate: Date? = nil
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        polaroidView.layer.cornerRadius = 10
//        imageView.layer.cornerRadius = 10
//        imageView.clipsToBounds = true
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "수정", style: .plain, target: self, action: nil)
//        navigationItem.rightBarButtonItem?.tintColor = .darkGray
//        
//        if let uid = self.uid, uid == UserDefaults.standard.integer(forKey: "uid") {
//            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "수정", style: .plain, target: self, action: nil)
//            
//            // 만약 수정가능 시간이라면
////            if true {
////                navigationItem.rightBarButtonItem?.tintColor = .white
////            } else {
////                navigationItem.rightBarButtonItem?.tintColor = .darkGray
////            }
//        }
//
//        guard let diaryID = did else { return }
//
//        NetworkManager.shared.fetchDiary(diaryID: diaryID) { [weak self] (result) in
//            switch result {
//            case .success(let content):
//                let imageString = content.data.img
//                guard let imageURL = URL(string: imageString) else { return }
//                self?.imageView.kf.setImage(with: imageURL)
//                self?.titleTextField.text = content.data.title
//                self?.writerLabel.text = "by \(content.data.nickname)"
//                self?.dateLabel.text = content.data.createdDate.date(type: .yearMonthDay)
//                self?.textView.text = content.data.content
//            case .failure(let error):
//                self?.showToast(message: error.localizedDescription, position: .bottom)
//            }
//        }
//    }
//}
