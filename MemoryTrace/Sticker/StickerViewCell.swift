//
//  StickerViewCell.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/14.
//

import UIKit

class StickerViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.collectionViewLayout = StickerLayout()
    }
    
    override func prepareForReuse() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
