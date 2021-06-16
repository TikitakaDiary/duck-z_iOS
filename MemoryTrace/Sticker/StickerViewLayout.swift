//
//  StickerViewLayout.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/16.
//

import UIKit

class StickerViewLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {return}
        self.itemSize = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0
    }
}
