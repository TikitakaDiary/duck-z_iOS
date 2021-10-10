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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var polaroidView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var commentButton: UIButton!
    
    let rightBarButton: UIButton = {
        let btn = UIButton()
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 9)
        btn.frame.size.width = 50
        btn.contentHorizontalAlignment = .right
        return btn
    }()

    private let disposeBag = DisposeBag()
    var viewModel: DiaryDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        configureUI()
        bind()
    }
    
    private func configureUI() {
        polaroidView.layer.cornerRadius = 10
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.addBorder()
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .asDriver()
            .drive(onNext: { recognizer in

            if recognizer.location(in: self.bottomBar).y > 0 { return }
                
            UIView.animate(withDuration: 0.2) {
                if self.bottomBar.alpha == 0 {
                    self.bottomBar.alpha = 1
                } else {
                    self.bottomBar.alpha = 0
                }
            } completion: { _ in
                if self.bottomBar.alpha == 0 {
                    self.bottomBar.isHidden = true
                } else {
                    self.bottomBar.isHidden = false
                }
            }
        }).disposed(by: disposeBag)
    }

    private func bind() {
        viewModel.content()
            .subscribe(on: MainScheduler.instance)
            .compactMap({ $0 })
            .do(onNext: { [unowned self] content in
                if content.uid == UserManager.uid {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightBarButton)
                    self.rightBarButton.setTitle("수정", for: .normal)
                    
                    if !content.modifiable {
                        self.rightBarButton.setTitleColor(.gray, for: .normal)
                    }
                }
            })
            .bind { content in
                self.titleTextField.text = content.title
                self.writerLabel.text = "by \(content.nickname)"
                self.dateLabel.text = content.createdDate.date(type: .yearMonthDay)
                self.textView.text = content.content
                self.imageView.kf.setImage(with: URL(string: content.img))
                guard content.commentCnt != 0 else { return }
                self.commentButton.setTitle(" " + String(content.commentCnt), for: .normal)
            }
            .disposed(by: disposeBag)
        
        viewModel.errorMessage()
            .subscribe(on: MainScheduler.instance)
            .bind { errorMessage in
                self.showToast(message: errorMessage, position: .bottom)
                self.textView.text = "일기 내용을 불러올 수 없습니다. 😥"
            }
            .disposed(by: disposeBag)

        rightBarButton.rx.tap
            .withLatestFrom(viewModel.content())
            .compactMap({ $0 })
            .observe(on: MainScheduler.instance)
            .bind { [unowned self] content in
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
        
        
        scrollView.rx.willBeginDragging
            .asDriver()
            .drive(onNext: { [weak self] _ in
                if self?.bottomBar.alpha == 1 {
                    UIView.animate(withDuration: 0.2) {
                        self?.bottomBar.alpha = 0
                    } completion: { _ in
                        self?.bottomBar.isHidden = true
                    }
                }
            })
            .disposed(by: disposeBag)

        scrollView.rx.didEndDecelerating
            .asDriver()
            .drive(onNext: { [unowned self] _ in
                if self.scrollView.contentOffset.y + 1 >= (self.scrollView.contentSize.height - self.scrollView.frame.size.height) || self.scrollView.contentOffset.y == 0{
                    if self.bottomBar.alpha == 0 {
                        UIView.animate(withDuration: 0.2) {
                            self.bottomBar.alpha = 1
                        } completion: { _ in
                            self.bottomBar.isHidden = false
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        commentButton.rx.tap
            .withLatestFrom(viewModel.content())
            .compactMap({ $0 })
            .observe(on: MainScheduler.instance)
            .bind { content in
                guard let commentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommentVC") as? CommentViewController else {return}
                    commentVC.did = content.did
                    self.navigationController?.pushViewController(commentVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name("updateCommentCount"))
            .bind { [unowned self] info in
                let commentCount = info.object as? Int ?? 0
                if commentCount != 0 {
                    commentButton.setTitle(" " + String(commentCount), for: .normal)
                }
            }
            .disposed(by: disposeBag)
    }
}

