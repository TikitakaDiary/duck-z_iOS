//
//  DiaryPolaroidLayout.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/04/29.
//

import UIKit

class DiaryPolaroidLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {return}
        let cellWidth = collectionView.frame.width * 0.872
        let cellHeight = cellWidth * 1.24
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        self.scrollDirection = .vertical
        self.sectionInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        self.minimumLineSpacing = 12
    }

}
