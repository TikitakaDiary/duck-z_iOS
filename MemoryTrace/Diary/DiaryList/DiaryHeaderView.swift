//
//  DiaryHeaderView.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/01.
//

import UIKit

class DiaryHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        dateLabel.text = nil
    }
}
