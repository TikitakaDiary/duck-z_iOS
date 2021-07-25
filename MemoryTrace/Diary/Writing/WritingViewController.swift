//
//  WritingViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/02.
//

import UIKit

class WritingViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var polaroidView: UIView!
    @IBOutlet weak var polaroidImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var scrollViewBotConst: NSLayoutConstraint!
    
    var isStickerAvailble: Bool = false
    var colorIndex: Int?
    var editType: EditType = .create
    var isPhotoChangeAvailable: Bool = false
    var content: Content?
    private let imagePicker = UIImagePickerController()
    private var stickerViewController: StickerViewController?
    private var _selectedStickerView:StickerView?
    lazy var isSendAvailable: Bool = true
    
    lazy private var stickerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.frame = polaroidImageView.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    private var selectedStickerView: StickerView? {
        get {
            return _selectedStickerView
        }
        set {
            if _selectedStickerView != newValue {
                if let selectedStickerView = _selectedStickerView {
                    selectedStickerView.showEditingHandlers = false
                }
                _selectedStickerView = newValue
            }
            if let selectedStickerView = _selectedStickerView {
                selectedStickerView.showEditingHandlers = true
                selectedStickerView.superview?.bringSubviewToFront(selectedStickerView)
            }
        }
    }
    
    private lazy var actionSheet: UIAlertController = {
        let actionSheet = UIAlertController(title: "사진 선택", message: nil, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1)
        
        let album = UIAlertAction(title: "사진 앨범", style: .default) { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let camera = UIAlertAction(title: "카메라", style: .default) { _ in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let background = UIAlertAction(title: "단색 배경", style: .default) { _ in
            let colorSettingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorSettingVC") as! ColorSettingViewController
            colorSettingViewController.modalPresentationStyle = .fullScreen
            colorSettingViewController.writer = self.writerLabel.text ?? ""
            colorSettingViewController.diaryTitle = self.titleTextField.text ?? ""
            colorSettingViewController.date = self.dateLabel.text ?? ""
            colorSettingViewController.stickerView = self.stickerView.snapshotView(afterScreenUpdates: true)
            colorSettingViewController.colorIndex = self.colorIndex
            self.present(colorSettingViewController, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
        }
        
        actionSheet.addAction(album)
        actionSheet.addAction(camera)
        actionSheet.addAction(background)
        actionSheet.addAction(cancel)
        
        return actionSheet
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        addNotification()
        configureUI()
        setupUI()
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        contentView.addGestureRecognizer(tapGesture)
        
        let polaroidImageViewTapGeture = UITapGestureRecognizer(target: self, action: #selector(tapPolaroidImageView(_:)))
        polaroidImageView.addGestureRecognizer(polaroidImageViewTapGeture)
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func configureUI() {
        self.polaroidImageView.addSubview(stickerView)
        polaroidView.layer.cornerRadius = 10
        polaroidImageView.layer.cornerRadius = 10
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        textView.tintColor = .white
        textView.tintColorDidChange()
        textView.delegate = self
    }
    
    private func setupUI() {
        toolbarSetup(textView: textView, textField: titleTextField)
        writerLabel.text = "by \(UserDefaults.standard.string(forKey: "name") ?? "")"
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        
        guard let year =  components.year, let month = components.month ,let day = components.day else { return }
        dateLabel.text = "\(year)년 \(month)월 \(day)일"
        
        switch editType {
        case .create:
            break
        case .modify:
            self.titleLabel.text = "일기 수정"
            if let content = self.content {
                self.polaroidImageView.kf.setImage(with: URL(string: content.img))
                self.titleTextField.text = content.title
                self.textView.text = content.content
                self.textView.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            }
        }
    }

    @objc private func tap(_ gesture: UITapGestureRecognizer) {
        selectedStickerView = nil
    }
    
    @objc private func tapPolaroidImageView(_ gesture: UITapGestureRecognizer) {
        if editType == .modify && isPhotoChangeAvailable == false {
            showPhotoEditAlert()
            return
        }
        
        if selectedStickerView != nil {
            selectedStickerView = nil
        } else {
            dismissStickerView()
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    private func showPhotoEditAlert() {
        let editAction = UIAlertAction(title: "편집하기", style: .default) { _ in
            self.isPhotoChangeAvailable = true
            self.polaroidImageView.image = UIImage(named: "photo")
        }
        
        showAlert(title: "사진 편집", message: "사진 편집 시, 부착한 스티커와 사진 모두 리셋됩니다. 그래도 편집하시겠습니까?", action: editAction)
    }
    
    @IBAction func didPressCancelButton(_ sender: UIButton) {
        let exitAction = UIAlertAction(title: "나가기", style: .destructive) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        var exitAlertMessage = ""
        switch editType {
        case .create:
            exitAlertMessage = "일기를 전달하지 않고 나갈시, 작성한 내용은 저장되지 않습니다"
        case .modify:
            exitAlertMessage = "일기를 저장하지 않고 나갈시, 수정한 내용은 반영되지 않습니다"
        }
        
        showAlert(title: "나가기", message: exitAlertMessage, action: exitAction)
    }
    
    @IBAction func didPressSendButton(_ sender: UIButton) {
        selectedStickerView = nil
        
        if scrollViewBotConst.constant != 0 {
            self.view.endEditing(true)
            scrollViewBotConst.constant = 0
        }
        
        guard let book = CurrentBook.shared.book, self.isSendAvailable else { return }
        
        guard let title = titleTextField.text, !title.getArrayAfterRegex(regex: "[^\\s]").isEmpty else {
            showToast(message: "제목을 입력해주세요!", position: .bottom)
            return
        }

        guard isStickerAvailble || (editType == .modify && !isPhotoChangeAvailable) else {
            showToast(message: "사진 혹은 배경색을 설정해주세요!", position: .bottom)
            return }
        
        guard let img = polaroidImageView.asImage(), let resizedImage = img.resizedImage(targetSize: CGSize(width: 300, height: 300))  else {return}
        
        let diaryContent = textView.text == "이곳을 눌러 일기를 작성해보세요!" ? "" : textView.text

        self.isSendAvailable = false
        
        func postNoti() {
            NotificationCenter.default.post(name: NSNotification.Name("updateDiary"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("updateBooks"), object: BookUpdateType.update)
        }
        
        switch editType {
        case .create:
            let writingContent = WritingContent(bookID: book.bid, title: title, content: diaryContent ?? "", image: resizedImage)
            NetworkManager.shared.createDiary(writingContent: writingContent) { [weak self] (result) in
                switch result {
                case .success(_):
                    postNoti()
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    self?.showToast(message: error.localizedDescription, position: .bottom)
                    self?.isSendAvailable = true
                }
            }
        case .modify:
            guard let did = self.content?.did else { return }
  
            let modifiedContent = ModifiedContent(diaryID: did, title: title, content: diaryContent ?? "", image: isPhotoChangeAvailable ? resizedImage : nil)
            NetworkManager.shared.modifyDiary(diaryID: did, modifiedContent: modifiedContent) { [weak self] result in
                switch result {
                case .success(_):
                    guard let presentingVC = self?.presentingViewController as? UINavigationController, let readingVC = presentingVC.viewControllers.last as? ReadingViewControllerRx, let did = self?.content?.did else { return }
 
                    readingVC.viewModel.fetch(diaryID: did)
                    postNoti()
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    self?.showToast(message: error.localizedDescription, position: .bottom)
                    self?.isSendAvailable = true
                }
            }
            
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func didPressStickerButton(_ sender: UIButton) {
        if editType == .modify && isPhotoChangeAvailable == false {
            showPhotoEditAlert()
            return
        }
        
        guard isStickerAvailble else {
            showToast(message: "사진이나 단색배경을 먼저 선택해주세요", position: .bottom)
            return }
        
        stickerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StickerVC") as? StickerViewController
        
        guard stickerViewController != nil else {return}
        
        self.addChild(stickerViewController!)
        stickerViewController?.delegate = self
        
        let stickerViewOriginY = polaroidView.frame.origin.y + 85 + polaroidImageView.frame.height + topbarHeight // 75
        
        stickerViewController!.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height - stickerViewOriginY)
        self.view.addSubview(stickerViewController!.view)
        
        UIView.transition(with: stickerViewController!.view, duration: 0.2, options: .curveLinear, animations: {
            self.stickerViewController!.view.frame.origin = CGPoint(x: 0, y: stickerViewOriginY)
        }, completion: nil)
    }
    
    @IBAction func didPressAlbumButton(_ sender: UIButton) {
        if editType == .modify && isPhotoChangeAvailable == false {
            showPhotoEditAlert()
            return
        }
        self.present(actionSheet, animated: true, completion: nil)
    }

    override func hideKeyboard(_ sender: Any) {
        super.hideKeyboard(sender)
        scrollViewBotConst.constant = 0
        activateAnimation(duration: 0.15, delay: 0)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        selectedStickerView = nil
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
//            let duration:TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            
            self.scrollViewBotConst.constant = keyboardHeight - (40 + self.view.safeAreaInsets.bottom)
            
            activateAnimation(duration: 0.15, delay: 0.05)
        }
    }
    
    private func activateAnimation(duration: TimeInterval, delay: TimeInterval) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: .curveEaseIn,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
    }
}

extension WritingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        dismissStickerView()
        if textView.text == "이곳을 눌러 일기를 작성해보세요!" {
            textView.text = ""
            textView.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "이곳을 눌러 일기를 작성해보세요!"
            textView.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        }
    }
}


extension WritingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        polaroidImageView.image = image
        colorIndex = nil
        isStickerAvailble = true
        dismiss(animated: true, completion: nil)
    }
}

extension WritingViewController: StickerViewControllerDelegate {
    func dismissStickerView() {
        guard stickerViewController != nil else { return }
        UIView.transition(with: stickerViewController!.view, duration: 0.2, options: .curveLinear, animations: {
            self.stickerViewController!.view.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
        }, completion: nil)
        selectedStickerView = nil
        stickerViewController?.removeFromParent()
    }
    
    func selectSticker(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        let stickerWidth = polaroidImageView.frame.width / 4
        imageView.frame = CGRect(x: 0, y: 0, width: stickerWidth, height: stickerWidth)
        
        let sticker = StickerView(contentView: imageView)
        sticker.center = CGPoint(x: polaroidImageView.frame.width / 2 , y: polaroidImageView.frame.height / 2)
        sticker.delegate = self
        sticker.setImage(UIImage.init(named: "delete")!, forHandler: StickerViewHandler.close)
        sticker.setImage(UIImage.init(named: "sticker_control")!, forHandler: StickerViewHandler.control)
        sticker.showEditingHandlers = false
        sticker.tag = 999
        stickerView.addSubview(sticker)
        self.selectedStickerView = sticker
    }
}

extension WritingViewController: StickerViewDelegate {
    func stickerViewDidTap(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
    }
    
    func stickerViewDidBeginMoving(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
    }
}
