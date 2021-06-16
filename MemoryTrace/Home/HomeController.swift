//
//  ViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/04/29.
//

import UIKit
import Kingfisher

enum BookUpdateType {
    case add
    case delete
    case update
}

class HomeController: UIViewController {
    
    @IBOutlet weak var noBookLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBOutlet weak var plusButton: UIButton!

    lazy var books: Books = Books()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi()
        setupCollectionView()
        
        bookCollectionView.dataSource = self
        bookCollectionView.delegate = self
        plusButton.layer.cornerRadius = 8
        fetchBookList(page:1)
        
        bookCollectionView.refreshControl = UIRefreshControl()
        bookCollectionView.refreshControl?.tintColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBooks(_:)), name: NSNotification.Name("updateBooks"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        ImageCache.default.clearMemoryCache()
    }
    
    @objc func updateBooks(_ notification: Notification) {
        guard let updateType = notification.object as? BookUpdateType else { return }
        fetchBookList(page: 1, updateType: updateType)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let name = UserDefaults.standard.string(forKey: "name") else {
            NetworkManager.shared.fetchUserInfo { [weak self] (result) in
                
                switch result {
                case .success(let response):
                    guard let data = response.data else {return}
                    let name = data.nickname
                    UserDefaults.standard.set(name, forKey: "name")
                    self?.nameLabel.text = name
                case .failure(let error):
                    self?.showToast(message: error.localizedDescription, position: .bottom)
                }
            }
            return}
        nameLabel.text = name
    }
    
    private func fetchBookList(page: Int, updateType: BookUpdateType = .update) {
        if updateType == .delete {
            guard let idx = CurrentBook.shared.cellIdx else { return }
            self.books.showingbooks.remove(at: idx)
            DispatchQueue.main.async {
                self.bookCollectionView.deleteItems(at: [IndexPath(item: idx, section: 0)])
            }
            return
        }

        NetworkManager.shared.fetchBookList(page: page) { [weak self] (result) in
            guard let strongSelf = self else {return}
            
            switch result {
            case .success(let bookList):
                let data = bookList.data
                if page == 1 {
                    self?.bookCollectionView.contentOffset = CGPoint(x: 0, y: 0)
                    switch updateType {
                    case .update:
                        self?.books.showingbooks = data.bookList
                    case .add:
                        DispatchQueue.main.async {
                            self?.books.showingbooks.insert(bookList.data.bookList[0], at: 0)
                        }
                    case .delete:
                        return
                    }
                } else {
                    strongSelf.books.showingbooks.append(contentsOf: data.bookList)
                }
                
                if strongSelf.books.showingbooks.isEmpty {
                    strongSelf.noBookLabel.isHidden = false
                } else {
                    strongSelf.noBookLabel.isHidden = true
                    
                    switch updateType {
                    case .add:
                        DispatchQueue.main.async {
                            self?.bookCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                        }
                    case .update:
                        DispatchQueue.main.async {
                            self?.bookCollectionView.reloadData()
                        }
                    case .delete:
                        return
                    }
                }
                
                strongSelf.books.nextPage = data.curPage + 1
                strongSelf.books.hasNext = data.hasNext
            case .failure(let error):
                self?.showToast(message: error.localizedDescription, position: .bottom)
            }
        }
    }
    
    @IBAction func didPressAddButton(_ sender: UIButton) {
        guard let decoratingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DecoratingVC") as? DecoratingViewController else {return}
        
        decoratingVC.books = books
        decoratingVC.modalPresentationStyle = .fullScreen
        self.present(decoratingVC, animated: true)
    }
    
    private func setupNavi() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "mypage"), style: .plain, target: self, action: #selector(didPressMyPage))
        self.navigationController?.navigationBar.tintColor = .white
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    @objc private func didPressMyPage() {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MypageVC") as? MypageViewController else {return}
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupCollectionView() {
        bookCollectionView.collectionViewLayout = DiaryBookLayout()
        let diaryBookCell = UINib(nibName: "DiaryBookCell", bundle: nil)
        self.bookCollectionView.register(diaryBookCell, forCellWithReuseIdentifier: "diaryBookCell")
    }
}

extension HomeController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.showingbooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "diaryBookCell", for: indexPath) as! DiaryBookCell
        
        let book = books.showingbooks[indexPath.row]
        
        cell.colorView.backgroundColor = BackgroundColor(rawValue: book.bgColor)?.color
        cell.titleLabel.text = book.title
        cell.turnLabel.text = "\(book.nickname) 작성 중"
        if let stickerImg = book.stickerImg, let imageURL = URL(string: stickerImg) {
            cell.coverImageView.kf.setImage(with: imageURL)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DiaryListVC") as? DiaryListViewController else {return}

        CurrentBook.shared.book = books.showingbooks[indexPath.row]
        CurrentBook.shared.cellIdx = indexPath.item
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if books.hasNext && indexPath.item == books.showingbooks.count - 10  {
            fetchBookList(page: books.nextPage)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let isRefreshing = bookCollectionView.refreshControl?.isRefreshing, isRefreshing {
            bookCollectionView.refreshControl?.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.fetchBookList(page: 1)
            }
        }
    }
}

