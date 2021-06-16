//
//  StickerCell.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/14.
//

import UIKit

class StickerCell: UICollectionViewCell {
    
    @IBOutlet weak var stickerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.stickerImageView.image = nil
    }
}
