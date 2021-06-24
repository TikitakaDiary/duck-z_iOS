//
//  MemberCell.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/19.
//

import UIKit

class MemberCell: UITableViewCell {
    
    static let identifier = "MemberCell"
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = 10
    }
}
