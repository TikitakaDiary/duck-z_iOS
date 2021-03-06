//
//  DecoratingViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/08.
//

import UIKit

enum EditType {
    case create
    case modify
}

class DecoratingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var stickerImageView: UIImageView!
    @IBOutlet weak var stickerView: UIView!
    @IBOutlet weak var coverColorLabel: UILabel!
    @IBOutlet weak var bookTitleTextView: UITextView!
    
    lazy private var hasSticker: Bool = false
    lazy var isCreateAvailable: Bool = true
    lazy var isStickerVCUp: Bool = false
    private var stickerViewController: StickerViewController?
    private var _selectedStickerView:StickerView?
    var editType: EditType = .create
    
    lazy var colorPickerView: ColorPickerView = {
        let colorIndex = self.editType == .create ? 11 : CurrentBook.shared.book?.bgColor
        let bundle = Bundle.init(for: self.classForCoder)
        let colorPickerView = bundle.loadNibNamed("ColorPickerView",
                                                  owner: self,
                                                  options: nil)?.first as! ColorPickerView
        colorPickerView.delegate = self
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerView.colorIndex = colorIndex
        return colorPickerView
    }()
    
    private var selectedStickerView: StickerView? {
        get {
            return _selectedStickerView
        }
        set {
            // if other sticker choosed then resign the handler
            if _selectedStickerView != newValue {
                if let selectedStickerView = _selectedStickerView {
                    selectedStickerView.showEditingHandlers = false
                }
                _selectedStickerView = newValue
            }
            // assign handler to new sticker added
            if let selectedStickerView = _selectedStickerView {
                selectedStickerView.showEditingHandlers = true
                selectedStickerView.superview?.bringSubviewToFront(selectedStickerView)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGeture()
        configureUI()
        setupUI()
    }
    
    private func addGeture() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func configureUI() {
        bookTitleTextView.textContainer.maximumNumberOfLines = 2
        coverView.layer.cornerRadius = 8
        coverView.clipsToBounds = true
        bookTitleTextView.tintColor = .white
        bookTitleTextView.tintColorDidChange()
        bookTitleTextView.delegate = self
        stickerView.clipsToBounds = true
        stickerImageView.clipsToBounds = true
        stickerImageView.isHidden = true
    }
    
    private func setupUI() {
        bookTitleTextView.text = "????????? ???????????????"
        stickerImageView.image = UIImage(named: "sticker_area")
        
        self.view.addSubview(colorPickerView)
        NSLayoutConstraint.activate([
            colorPickerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.83),
            colorPickerView.topAnchor.constraint(equalTo: coverColorLabel.bottomAnchor, constant: 16),
            colorPickerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        switch editType {
        case .create:
            titleLabel.text = "????????? ?????????"
            rightButton.setTitle("??????", for: .normal)
        case .modify:
            titleLabel.text = "????????? ?????? ??????"
            rightButton.setTitle("??????", for: .normal)
            guard let book = CurrentBook.shared.book else { return }
            bookTitleTextView.text = book.title
            bookTitleTextView.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            if let stickerImg = book.stickerImg, let imageURL = URL(string: stickerImg) {
                hasSticker = true
                stickerImageView.kf.setImage(with: imageURL)
                stickerImageView.isHidden = false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    @IBAction func didPressCancelButton(_ sender: UIButton) {
        let exitAction: UIAlertAction = UIAlertAction(title: "?????????", style: .destructive) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        switch editType {
        case .create:
            showAlert(title: "?????????", message: "???????????? ???????????? ?????? ?????????,\n ????????? ????????? ???????????? ????????????.", action: exitAction)
        case .modify:
            showAlert(title: "?????????", message: "???????????? ???????????? ?????? ?????????,\n ????????? ????????? ???????????? ????????????.", action: exitAction)
        }
    }
    
    @IBAction func didPressCreateButton(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if bookTitleTextView.text == "????????? ???????????????" || bookTitleTextView.text.getArrayAfterRegex(regex: "[^\\s]").isEmpty {
            showToast(message: "????????? ??????????????????!", position: .bottom)
            return
        }
        
        guard let bookTitle = bookTitleTextView.text, self.isCreateAvailable else {return}
        
        self.isCreateAvailable = false
        var image: UIImage? = nil
        if stickerView.subviews.filter({$0.tag == 999}).count > 0 {
            if let img = stickerView.asImage() {
                image = img
            }
        }
        
        switch self.editType {
        case .create:
            let bookCover = BookCover(bgColor: colorPickerView.currentButton.tag, title: bookTitle, stickerImage: image)
            
            NetworkManager.shared.createBook(bookCover: bookCover) { [weak self] (result) in
                switch result {
                case .success(_):
                    NotificationCenter.default.post(name: NSNotification.Name("updateBooks"), object: BookUpdateType.add)
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    self?.showToast(message: error.localizedDescription, position: .bottom)
                    self?.isCreateAvailable = true
                }
            }
        case .modify:
            guard let bid = CurrentBook.shared.book?.bid else {return}
            let modifiedImage = hasSticker ? stickerImageView.image : image
            let modifiedBookCover = BookCover(bgColor: colorPickerView.currentButton.tag, title: bookTitle, stickerImage: modifiedImage, bid: bid)
            
            NetworkManager.shared.modifyBookCover(bookCover: modifiedBookCover) { [weak self] (result) in
                
                switch result {
                case .success(_):
                    NotificationCenter.default.post(name: NSNotification.Name("updateBooks"), object: BookUpdateType.update)
                    NotificationCenter.default.post(name: NSNotification.Name("updateBookName"), object: bookTitle)
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    self?.showToast(message: error.localizedDescription, position: .bottom)
                    self?.isCreateAvailable = true
                }
                
            }
        }
    }
    
    @IBAction func didPressStickerButton(_ sender: UIButton) {
        if editType == .modify && hasSticker {
            let modifyAction = UIAlertAction(title: "????????????", style: .destructive) { [weak self] _ in
                self?.hasSticker = false
                self?.showUpStickerViewController()
                self?.stickerImageView.image = UIImage(named: "sticker_area")
            }
            showAlert(title: "????????? ??????", message: "????????? ?????????, ?????? ???????????? ???????????????. ????????? ?????????????????????????", action: modifyAction)
            return
        }
        
        showUpStickerViewController()
    }
    
    private func showUpStickerViewController() {
        stickerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StickerVC") as? StickerViewController
        
        guard stickerViewController != nil else {return}
        self.addChild(stickerViewController!)
        stickerViewController?.delegate = self
        
        let stickerViewOriginY = coverColorLabel.frame.origin.y + coverColorLabel.frame.height + 5
        
        stickerViewController!.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height - stickerViewOriginY)
        self.view.addSubview(stickerViewController!.view)
        
        UIView.transition(with: stickerViewController!.view, duration: 0.2, options: .curveLinear, animations: {
            self.stickerViewController!.view.frame.origin = CGPoint(x: 0, y: stickerViewOriginY)
        }, completion: nil)
        
        stickerImageView.isHidden = false
        isStickerVCUp = true
    }
}

extension DecoratingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let stickerSelectionView = stickerViewController?.view, touch.view?.isDescendant(of: stickerSelectionView) == true {
            return false
        }
        
        if let selectedStickerView = self.selectedStickerView, touch.view?.isDescendant(of: selectedStickerView) == true {
            return false
        }
        
        if !isStickerVCUp && !hasSticker {
            stickerImageView.isHidden = true
        }
        
        selectedStickerView = nil
        return true
    }
}

extension DecoratingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        dismissStickerView()
        if textView.text == "????????? ???????????????" {
            textView.text = ""
            textView.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "????????? ???????????????"
            textView.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        }
    }
}

extension DecoratingViewController: StickerViewControllerDelegate {
    func dismissStickerView() {
        guard stickerViewController != nil else { return }
        
        UIView.transition(with: stickerViewController!.view, duration: 0.2, options: .curveLinear) {
            self.stickerViewController!.view.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
        } completion: { _ in
            self.stickerViewController?.removeFromParent()
            self.stickerViewController = nil
        }
        self.selectedStickerView = nil
        stickerImageView.isHidden = true
        isStickerVCUp = false
    }
    
    func selectSticker(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        let stickerWidth = stickerView.frame.width / 4
        
        imageView.frame = CGRect(x: 0, y: 0, width: stickerWidth, height: stickerWidth)
        
        let sticker = StickerView(contentView: imageView)
        sticker.center = CGPoint(x: stickerView.frame.width / 2 , y: stickerView.frame.height / 2)
        sticker.delegate = self
        sticker.setImage(UIImage.init(named: "delete")!, forHandler: StickerViewHandler.close)
        sticker.setImage(UIImage.init(named: "sticker_control")!, forHandler: StickerViewHandler.control)
        sticker.showEditingHandlers = false
        sticker.tag = 999
        stickerView.addSubview(sticker)
        self.selectedStickerView = sticker
    }
}

extension DecoratingViewController: ColorPickerDelegate {
    func changeColor(colorIndex: Int) {
        coverView.backgroundColor = BackgroundColor(rawValue: colorIndex)?.color
    }
}

extension DecoratingViewController: StickerViewDelegate {
    func stickerViewDidTap(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
        if stickerImageView.isHidden {
            stickerImageView.isHidden = false
        }
    }
    
    func stickerViewDidBeginMoving(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
        if stickerImageView.isHidden {
            stickerImageView.isHidden = false
        }
    }
}
