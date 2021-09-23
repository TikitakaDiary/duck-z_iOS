//
//  DiaryMiniLayout.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/04/29.
//

import UIKit

class DiaryMiniLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {return}
        let padding = 0.064 * collectionView.frame.width
        let cellWidth = (collectionView.frame.width - (24+padding*2)) / 4
        let cellHeight = cellWidth
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        self.scrollDirection = .vertical
        self.sectionInset = UIEdgeInsets(top: 12, left: padding, bottom: 12, right: padding)
        self.minimumLineSpacing = 8
        self.minimumInteritemSpacing = 8
    }
}
