//
//  ColorPickerView.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/06/10.
//

import UIKit

protocol ColorPickerDelegate: AnyObject {
    func changeColor(colorIndex: Int)
}

class ColorPickerView: UIView {
    
    weak var delegate: ColorPickerDelegate?
    
    @IBOutlet var colorButtons: [CircleButton]!
    var currentButton: UIButton = UIButton()
    var colorIndex: Int? {
        didSet {
            if let index = colorIndex {
                self.currentButton = colorButtons[index]
                self.currentButton
                    .layer.borderColor = UIColor.white.cgColor
                self.currentButton
                    .layer.borderWidth = 2
                delegate?.changeColor(colorIndex: index)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func didPressColorButton(_ sender: UIButton) {
        currentButton.layer.borderWidth = 0
        sender.layer.borderColor = UIColor.white.cgColor
        sender.layer.borderWidth = 2
        currentButton = sender
        self.delegate?.changeColor(colorIndex: sender.tag)
    }
}


