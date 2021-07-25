//
//  ReadingViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/06/01.
//

import UIKit
import Kingfisher
import RxSwift

class ReadingViewControllerRx: UIViewController {
    
    @IBOutlet weak var polaroidView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    private let disposeBag = DisposeBag()
    var viewModel: DiaryDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    private func configureUI() {
        polaroidView.layer.cornerRadius = 10
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: self, action: nil)
    }
    
    private func bind() {
        viewModel.content()
            .subscribe(on: MainScheduler.instance)
            .compactMap({ $0 })
            .do(onNext: { [weak self] content in
                if content.uid == UserDefaults.standard.integer(forKey: "uid") {
                    self?.navigationItem.rightBarButtonItem?.title = "수정"
                    if !content.modifiable {
                        self?.navigationItem.rightBarButtonItem?.tintColor = .gray
                    }
                } else {
                    self?.navigationItem.rightBarButtonItem = nil
                }
            })
            .observe(on: MainScheduler.instance)
            .bind { content in
                self.titleTextField.text = content.title
                self.writerLabel.text = "by \(content.nickname)"
                self.dateLabel.text = content.createdDate.date(type: .yearMonthDay)
                self.textView.text = content.content
                self.imageView.kf.setImage(with: URL(string: content.img))
            }
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .withLatestFrom(viewModel.content())
            .compactMap({ $0 })
            .observe(on: MainScheduler.instance)
            .bind { content in
                if content.modifiable {
                    if let writingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WritingVC") as? WritingViewController {
                        writingVC.editType = .modify
                        writingVC.content = content
                        writingVC.modalPresentationStyle = .fullScreen
                        self.present(writingVC, animated: true)
                    }
                } else {
                    self.showToast(message: "일기 수정은 작성 후 30분 내에만 가능해요!", position: .bottom)
                }
            }
            .disposed(by: disposeBag)
    }
}

