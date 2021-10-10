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
    
    let viewModel = HomeViewModel(profileStorage: ProfileStorage())
    
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

    }
    
    private func setupCollectionView() {
        bookCollectionView.refreshControl = UIRefreshControl()
        bookCollectionView.refreshControl?.tintColor = .white
        bookCollectionView.collectionViewLayout = DiaryBookLayout()
        let diaryBookCell = UINib(nibName: "DiaryBookCell", bundle: nil)
        self.bookCollectionView.register(diaryBookCell, forCellWithReuseIdentifier: "DiaryBookCell")
    }
    
    private func bind() {
        self.viewModel.noBooksLabelIsHidden
            .observe(on: MainScheduler.instance)
            .bind(to: noBookLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        self.viewModel.error
            .asDriver(onErrorJustReturn: .unknown)
            .drive(onNext: { [weak self] error in
                self?.showToast(message: error.description, position: .bottom)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.bookList
            .asDriver(onErrorJustReturn: [])
            .drive(bookCollectionView.rx.items(cellIdentifier: "DiaryBookCell", cellType: DiaryBookCell.self)) {
                index, book, cell in

                cell.colorView.backgroundColor = BackgroundColor(rawValue: book.bgColor)?.color
                cell.titleLabel.text = book.title
                cell.turnLabel.text = book.nickname
                
                if let stickerImg = book.stickerImg, let imageURL = URL(string: stickerImg) {
                    cell.coverImageView.kf.setImage(with: imageURL)
                }
            }
            .disposed(by: disposeBag)
      
        self.viewModel.userProfile
            .map({ $0.nickname })
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        Observable
            .zip(bookCollectionView.rx
                    .itemSelected, bookCollectionView.rx
                        .modelSelected(Book.self))
            .observe(on: MainScheduler.instance)
            .bind { [weak self] indexPath, book in
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DiaryListVC") as? DiaryListViewController else {return}
                
                CurrentBook.shared.book = book
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        bookCollectionView.rx
            .willDisplayCell
            .bind(onNext: { [unowned self] _, indexPath in
                if indexPath.item == self.viewModel.bookList.value.count - 3 && self.viewModel.isFetching == false && self.viewModel.hasNext {
                    self.viewModel.currentPage.accept(self.viewModel.currentPage.value + 1)
                }
            })
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .bind { [unowned self] _ in
                if let decoratingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DecoratingVC") as? DecoratingViewController {
                    decoratingVC.modalPresentationStyle = .fullScreen
                    self.present(decoratingVC, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        bookCollectionView.rx
            .didEndDecelerating
            .asDriver()
            .drive(onNext: { [unowned self] _ in
                if let isRefreshing = self.bookCollectionView.refreshControl?.isRefreshing, isRefreshing {
                    self.bookCollectionView.refreshControl?.endRefreshing()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.viewModel.pullToRefresh.accept(())
                    }
                }
            })
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .bind { [unowned self] _ in
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MypageVC") as? MypageViewController {
                    vc.profileStorage = self.viewModel.profileStorage
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name("updateBooks"))
            .bind { [unowned self] _ in
                self.bookCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                self.viewModel.pullToRefresh.accept(())
            }
            .disposed(by: disposeBag)
    }
}
