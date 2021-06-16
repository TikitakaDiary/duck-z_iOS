//
//  CircleButton.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/08.
//

import UIKit

class CircleButton: UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.width / 2
    }
}
