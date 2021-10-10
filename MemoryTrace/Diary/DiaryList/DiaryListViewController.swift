//
//  DiaryListViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/04/29.
//

import UIKit
import Kingfisher

enum Layout {
    case polaroid
    case grid
}

class DiaryListViewController: UIViewController {
    
    @IBOutlet weak var diaryCollectionView: UICollectionView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var noDiaryLabel: UILabel!
    
    private var layout: Layout = .polaroid
    private var isMyTurn: Bool?
    private var isFetching: Bool = false
    private var currentTurnName: String = ""

    lazy var page: Int = 1
    lazy var hasNextPage: Bool = false
    
    private var diaryList: [[DiaryInfo]] = [] {
        didSet {
            if diaryList.isEmpty {
                noDiaryLabel.isHidden = false
            } else {
                noDiaryLabel.isHidden = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bookTitleLabel.text = CurrentBook.shared.book?.title
        setupCollectionView()
        setupNavi()
        fetchDiaryList(page: page)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDiary(_:)), name: NSNotification.Name("updateDiary"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBookName(_:)), name: NSNotification.Name("updateBookName"), object: nil)
    }

    override func viewDidLayoutSubviews() {
        bookTitleLabel.frame.size.height = bookTitleLabel.frame.height + 8
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        ImageCache.default.clearMemoryCache()
    }
    
    private func setupCollectionView() {
        diaryCollectionView.delegate = self
        diaryCollectionView.dataSource = self
        diaryCollectionView.refreshControl = UIRefreshControl()
        diaryCollectionView.refreshControl?.tintColor = .white
        diaryCollectionView.collectionViewLayout = DiaryPolaroidLayout()
        
        let polaroidCell = UINib(nibName: "DiaryPolaroidCell", bundle: nil)
        let miniCell = UINib(nibName: "DiaryMiniCell", bundle: nil)
        let firstHeaderView = UINib(nibName: "DiaryFirstHeaderView", bundle: nil)
        let headerView = UINib(nibName: "DiaryHeaderView", bundle: nil)
        
        self.diaryCollectionView.register(polaroidCell, forCellWithReuseIdentifier: "polaroidCell")
        self.diaryCollectionView.register(miniCell, forCellWithReuseIdentifier: "miniCell")
        self.diaryCollectionView.register(firstHeaderView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "diaryFirstHeaderView")
        self.diaryCollectionView.register(headerView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "diaryHeaderView")
    }
    
    private func setupNavi() {
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "setting"), style: .plain, target: self, action: #selector(didPressSetting))
        rightBarButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 7)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func updateDiary(_ notification: Notification) {
        self.page = 1
        self.fetchDiaryList(page: self.page)
    }
    
    @objc func updateBookName(_ notification: Notification) {
        guard let bookName = notification.object as? String else { return }
        self.bookTitleLabel.text = bookName
    }
    
    private func fetchDiaryList(page: Int) {
        guard let book = CurrentBook.shared.book, isFetching == false else { return }
        
        isFetching = true
        
        NetworkManager.shared.fetchDiaryList(bookID: book.bid, page: page, size: 40) { [weak self] (result) in
            
            switch result {
            case .success(let diaryInfo):
                if page == 1 {
                    self?.diaryList = []
                }
                    
                self?.isMyTurn = diaryInfo.data.whoseTurn == UserManager.uid
                self?.appendList(new: diaryInfo.data.diaryList)
                self?.hasNextPage = diaryInfo.data.hasNext
                self?.currentTurnName = diaryInfo.data.nickname
                DispatchQueue.main.async {
                    self?.diaryCollectionView.reloadData()
                    self?.isFetching = false
                }
            case .failure(let error):
                if page == 1 {
                    self?.diaryList = []
                    DispatchQueue.main.async {
                        self?.diaryCollectionView.reloadData()
                    }
                }
                self?.page -= 1
                self?.showToast(message: error.localizedDescription, position: .bottom)
                self?.isFetching = false
            }
        }
    }

    private func appendList(new list: [DiaryInfo]) {
        list.forEach {
            if diaryList.isEmpty || !compareDate(firstDate: diaryList.last!.last!.createdDate, secondDate: $0.createdDate) {
                diaryList.append([$0])
            } else {
                diaryList[diaryList.endIndex - 1].append($0)
            }
        }
    }

    private func compareDate(firstDate: String, secondDate: String) -> Bool {
        let firstDateComponent = firstDate.split(separator: "-")
        let secondDateComponent = secondDate.split(separator: "-")
        
        if (firstDateComponent[0] == secondDateComponent[0]) && (firstDateComponent[1] == secondDateComponent[1]) {
            return true
        } else {
            return false
        }
    }

    @IBAction func didPressLayoutButton(_ sender: UIButton) {
        switch layout {
        case .polaroid:
            diaryCollectionView.collectionViewLayout = DiaryMiniLayout()
            layout = .grid
            sender.setImage(UIImage(named: "grid"), for: .normal)
        case .grid:
            diaryCollectionView.collectionViewLayout = DiaryPolaroidLayout()
            sender.setImage(UIImage(named: "polaroid"), for: .normal)
            layout = .polaroid
        }
        
        diaryCollectionView.setContentOffset(CGPoint(x:0,y:0), animated: false)
        DispatchQueue.main.async {
            self.diaryCollectionView.reloadData()
        }
    }
    
    @objc func didPressSetting() {
        let diarySettingVC = DiarySettingViewController()
        self.navigationController?.pushViewController(diarySettingVC, animated: true)
    }
}

extension DiaryListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let isMyTurn = self.isMyTurn else { return
            0
        }
        return diaryList.isEmpty && isMyTurn ? 1 : diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryList.isEmpty ? 0 : diaryList[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let diaryInfo = diaryList[indexPath.section][indexPath.item]

        if layout == .polaroid {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "polaroidCell", for: indexPath) as! DiaryPolaroidCell

            guard let imageURL = URL(string: diaryInfo.img) else { return cell}
            cell.titleLabel.text = diaryInfo.title
            cell.imageView.kf.setImage(with: imageURL)
            cell.writerLabel.text = "by \(diaryInfo.nickname)"
            cell.dateLabel.text = diaryInfo.createdDate.date(type: .yearMonthDay)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "miniCell", for: indexPath) as! DiaryMiniCell

            guard let imageURL = URL(string: diaryInfo.img) else { return cell}
            cell.imageView.kf.setImage(with: imageURL)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let isMyTurn = self.isMyTurn else { return UICollectionReusableView()}
        
        if indexPath.section == 0 {
            let firstHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "diaryFirstHeaderView", for: indexPath) as! DiaryFirstHeaderView
            
            firstHeader.delegate = self
            
            if isMyTurn {
                firstHeader.turnInfoView.isHidden = true
                firstHeader.yourTurnButton.isHidden = false
            } else {
                firstHeader.turnInfoView.isHidden = false
                firstHeader.nameLabel.text = self.currentTurnName
                firstHeader.yourTurnButton.isHidden = true
            }

            if diaryList.isEmpty {
                firstHeader.dateLabel.text = nil
            } else {
                firstHeader.dateLabel.text = diaryList[indexPath.section].last?.createdDate.date(type: .yearMonth)
            }
            
            return firstHeader
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "diaryHeaderView", for: indexPath) as! DiaryHeaderView
            headerView.dateLabel.text = diaryList[indexPath.section].last?.createdDate.date(type: .yearMonth)
            return headerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = self.view.frame.width
        return section == 0 ? CGSize(width: width, height: width * 0.33) : CGSize(width: width, height: width * 0.125)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let readingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReadingVC") as? ReadingViewControllerRx else {return}

        let diaryInfo = diaryList[indexPath.section][indexPath.item]
        let diaryDetail = Content(modifiable: false, uid: -999, did: diaryInfo.did, nickname: diaryInfo.nickname, title: diaryInfo.title, img: diaryInfo.img, content: "", template: 0, createdDate: diaryInfo.createdDate, commentCnt: 0)
        
        readingVC.viewModel = DiaryDetailViewModel(diaryDetail: diaryDetail)
        self.navigationController?.pushViewController(readingVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard hasNextPage && isFetching == false else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        switch layout {
        case .polaroid:
            if offsetY > contentHeight - (scrollView.frame.height * 10) {
                self.page += 1
                fetchDiaryList(page: self.page)
            }
        case .grid:
            if offsetY > contentHeight - (scrollView.frame.height * 3/2) {
                self.page += 1
                fetchDiaryList(page: self.page)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let isRefreshing = diaryCollectionView.refreshControl?.isRefreshing, isRefreshing {
            diaryCollectionView.refreshControl?.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.page = 1
                self.fetchDiaryList(page: self.page)
            }
        }
    }
}

extension DiaryListViewController: PresentDelegate {
    func present() {
        guard let writingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WritingVC") as? WritingViewController else {return}
        writingVC.modalPresentationStyle = .fullScreen
        self.present(writingVC, animated: true)
    }
}
