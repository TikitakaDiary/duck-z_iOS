//
//  DiaryHeaderWithButtonView.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/02.
//

import UIKit

protocol PresentDelegate: AnyObject {
    func present()
}

class DiaryHeaderWithButtonView: UICollectionReusableView {
    
    weak var delegate: PresentDelegate?
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        dateLabel.text = nil
    }
    
    @IBAction func didPressYourTurnButton(_ sender: UIButton) {
        delegate?.present()
    }
}
