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
        let cellWidth = (collectionView.frame.width - 72) / 4
        let cellHeight = cellWidth
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        self.scrollDirection = .vertical
        self.sectionInset = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        self.minimumLineSpacing = 8
        self.minimumInteritemSpacing = 8
    }
}
