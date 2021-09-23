//
//  HomeControllerRX.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/06/29.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

enum BookUpdateType {
    case add
    case delete
    case update
}

class HomeControllerRx: UIViewController {
    
    @IBOutlet weak var noBookLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBOutlet weak var plusButton: UIButton!
    
    private let disposeBag = DisposeBag()
    let viewModel = HomeViewModel(bookStorage: BookStorage(), profileStorage: ProfileStorage())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plusButton.layer.cornerRadius = 8
        
        setupNavi()
        setupCollectionView()
        bind()
    }

    override func didReceiveMemoryWarning() {
        ImageCache.default.clearMemoryCache()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupCollectionView() {
        bookCollectionView.refreshControl = UIRefreshControl()
        bookCollectionView.refreshControl?.tintColor = .white
        bookCollectionView.collectionViewLayout = DiaryBookLayout()
        let diaryBookCell = UINib(nibName: "DiaryBookCell", bundle: nil)
        self.bookCollectionView.register(diaryBookCell, forCellWithReuseIdentifier: "DiaryBookCell")
    }
    
    private func setupNavi() {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "mypage"), style: .plain, target: self, action: nil)
        rightBarButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 7)
        navigationItem.rightBarButtonItem = rightBarButton
        
        self.navigationController?.navigationBar.tintColor = .white
 
        let configuration = UIImage.SymbolConfiguration(weight: .semibold)
        navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "chevron.left", withConfiguration: configuration)?.withRenderingMode(.automatic).withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -18, bottom: 0, right: 0))
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.automatic).withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -18, bottom: 0, right: 0))
        self.navigationItem.backButtonTitle = ""
    }
    
    private func bind() {
        self.viewModel.isReceivedFCM
            .filter({ $0 == true })
            .bind { _ in
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DiaryListVC") as? DiaryListViewController {
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name("updateBooks"))
            .bind { [weak self] _ in
                self?.bookCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false) 
                self?.viewModel.refresh()
            }
            .disposed(by: disposeBag)
        
        self.viewModel.bookList
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] books in
                if books.isEmpty {
                    self?.noBookLabel.isHidden = false
                } else {
                    self?.noBookLabel.isHidden = true
                }
            })
            .drive(bookCollectionView.rx.items(cellIdentifier: "DiaryBookCell", cellType: DiaryBookCell.self)) {
                index, book, cell in
                cell.colorView.backgroundColor = BackgroundColor(rawValue: book.bgColor)?.color
                cell.titleLabel.text = book.title
                cell.turnLabel.text = "\(book.nickname) 작성 중"
                if let stickerImg = book.stickerImg, let imageURL = URL(string: stickerImg) {
                    cell.coverImageView.kf.setImage(with: imageURL)
                }
            }
            .disposed(by: disposeBag)
        
        self.viewModel.userProfile
            .map({ $0.nickname })
            .observe(on: MainScheduler.instance)
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        Observable
            .zip(bookCollectionView.rx
                    .itemSelected, bookCollectionView.rx
                        .modelSelected(Book.self))
            .observe(on: MainScheduler.instance)
            .bind { [unowned self] indexPath, book in
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DiaryListVC") as? DiaryListViewController else {return}

                CurrentBook.shared.book = book
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        bookCollectionView.rx
            .willDisplayCell
            .subscribe(onNext: { [unowned self] cell, indexPath in
                viewModel.fetch(indexPath: indexPath)
            })
            .disposed(by: disposeBag)
        
        bookCollectionView.rx
            .didEndDecelerating
            .asDriver()
            .drive(onNext: { [weak self] _ in
                if let isRefreshing = self?.bookCollectionView.refreshControl?.isRefreshing, isRefreshing {
                    self?.bookCollectionView.refreshControl?.endRefreshing()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self?.viewModel.refresh()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .bind { _ in  
                if let decoratingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DecoratingVC") as? DecoratingViewController {
                    decoratingVC.modalPresentationStyle = .fullScreen
                    self.present(decoratingVC, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .bind { _ in
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MypageVC") as? MypageViewController {
                    vc.profileStorage = self.viewModel.profileStorage
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}
