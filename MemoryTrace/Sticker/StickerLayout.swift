//
//  StickerLayout.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/14.
//

import UIKit

class StickerLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {return}
//        let spacing = collectionView.frame.width * 0.0746
        let spacing = collectionView.frame.width * 0.04
        let cellWidth = (collectionView.frame.width - (spacing * 5)) / 4
        self.itemSize = CGSize(width: cellWidth, height: cellWidth)
        self.scrollDirection = .vertical
        self.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        self.minimumLineSpacing = spacing
        self.minimumInteritemSpacing = spacing
    }
}
