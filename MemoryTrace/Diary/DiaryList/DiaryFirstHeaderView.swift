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

class DiaryFirstHeaderView: UICollectionReusableView {
    
    weak var delegate: PresentDelegate?
    
    @IBOutlet weak var turnInfoView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var yourTurnButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        turnInfoView.layer.cornerRadius = 8
    }
    
    override func prepareForReuse() {
        dateLabel.text = nil
        nameLabel.text = nil
    }
    
    @IBAction func didPressYourTurnButton(_ sender: UIButton) {
        delegate?.present()
    }
}
