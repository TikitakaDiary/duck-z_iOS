//
//  ColorViewController.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/06/01.
//

import UIKit

class ColorSettingViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var polaroidView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var diaryTitle: String = ""
    var date: String = ""
    var writer: String = ""
    var colorIndex: Int?
    weak var stickerView: UIView!
    
    lazy var colorPickerView: ColorPickerView = {
        let bundle = Bundle.init(for: self.classForCoder)
        let colorPickerView = bundle.loadNibNamed("ColorPickerView",
                                                  owner: self,
                                                  options: nil)?.first as! ColorPickerView
        colorPickerView.delegate = self
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerView.colorIndex = colorIndex ?? 11
        return colorPickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        polaroidView.layer.cornerRadius = 10
        self.imageView.layer.cornerRadius = 10
        self.view.addSubview(colorPickerView)
        
        NSLayoutConstraint.activate([
            colorPickerView.leadingAnchor.constraint(equalTo: polaroidView.leadingAnchor, constant: 12),
            colorPickerView.trailingAnchor.constraint(equalTo: polaroidView.trailingAnchor, constant: -12),
            colorPickerView.topAnchor.constraint(equalTo: polaroidView.bottomAnchor, constant: 30)
        ])

        titleTextField.text = diaryTitle
        dateLabel.text = date
        writerLabel.text = writer
        imageView.addSubview(stickerView)
    }
    
    @IBAction func didPressCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressSaveButton(_ sender: UIButton) {
        guard let presentingVC = presentingViewController as? WritingViewController else { return }
        presentingVC.polaroidImageView.image = nil
        presentingVC.polaroidImageView.backgroundColor = colorPickerView.currentButton.backgroundColor
        presentingVC.colorIndex = colorPickerView.currentButton.tag
        presentingVC.isStickerAvailble = true
        self.dismiss(animated: true, completion: nil)
    }
}

extension ColorSettingViewController: ColorPickerDelegate {
    func changeColor(colorIndex: Int) {
        imageView.backgroundColor = BackgroundColor(rawValue: colorIndex)?.color
    }
}
