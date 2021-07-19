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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.view.backgroundColor = UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1)
    }
}
