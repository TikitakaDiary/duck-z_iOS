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
    var books: Books!
    
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

        self.view.addSubview(colorPickerView)
        bookTitleTextView.text = "제목을 입력하세요"
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            colorPickerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.83),
            colorPickerView.topAnchor.constraint(equalTo: coverColorLabel.bottomAnchor, constant: 16),
            colorPickerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        coverView.layer.cornerRadius = 8
        coverView.clipsToBounds = true
        bookTitleTextView.tintColor = .white
        bookTitleTextView.tintColorDidChange()
        bookTitleTextView.delegate = self
        stickerView.clipsToBounds = true
        stickerImageView.clipsToBounds = true
        stickerImageView.isHidden = true
        stickerImageView.image = UIImage(named: "sticker_area")
        
        bookTitleTextView.textContainer.maximumNumberOfLines = 2
        
        switch editType {
        case .create:
            titleLabel.text = "일기장 만들기"
            rightButton.setTitle("생성", for: .normal)
        case .modify:
            titleLabel.text = "일기장 표지 수정"
            rightButton.setTitle("저장", for: .normal)
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
        let exitAction: UIAlertAction = UIAlertAction(title: "나가기", style: .destructive) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        switch editType {
        case .create:
            showAlert(title: "나가기", message: "일기장을 생성하지 않고 나갈시,\n 작성한 내용은 저장되지 않습니다.", action: exitAction)
        case .modify:
            showAlert(title: "나가기", message: "일기장을 수정하지 않고 나갈시,\n 수정한 내용은 반영되지 않습니다.", action: exitAction)
        }
    }
    
    @IBAction func didPressCreateButton(_ sender: UIButton) {
        if bookTitleTextView.text == "제목을 입력하세요" || bookTitleTextView.text.getArrayAfterRegex(regex: "[^\\s]").isEmpty {
            showToast(message: "제목을 입력해주세요!", position: .bottom)
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
            let modifiedBookCover = ModifiedBookCover(bgColor: colorPickerView.currentButton.tag, title: bookTitle, stickerImage: modifiedImage, bid: bid)

            NetworkManager.shared.modifyBookCover(bookCover: modifiedBookCover) { [weak self] (result) in
                
                switch result {
                case .success(_):
                    NotificationCenter.default.post(name: NSNotification.Name("updateBooks"), object: BookUpdateType.update)
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
            let modifyAction = UIAlertAction(title: "수정하기", style: .destructive) { [weak self] _ in
                self?.hasSticker = false
                self?.showUpStickerViewController()
                self?.stickerImageView.image = UIImage(named: "sticker_area")
            }
            showAlert(title: "스티커 수정", message: "스티커 수정시, 현재 스티커는 리셋됩니다. 그래도 수정하시겠습니까?", action: modifyAction)
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
        if textView.text == "제목을 입력하세요" {
            textView.text = ""
            textView.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "제목을 입력하세요"
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
