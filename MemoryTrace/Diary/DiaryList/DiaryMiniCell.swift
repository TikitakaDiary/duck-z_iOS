//
//  DiaryMiniCell.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/04/29.
//

import UIKit

class DiaryMiniCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
