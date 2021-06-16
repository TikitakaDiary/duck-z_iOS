//
//  DiaryBookCell.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/04/29.
//

import UIKit

class DiaryBookCell: UICollectionViewCell {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        colorView.backgroundColor = nil
        titleLabel.text = nil
        turnLabel.text = nil
        coverImageView.image = nil
    }
}
