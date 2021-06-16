//
//  UILabel.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/09.
//

import UIKit

extension UILabel {
    @IBInspectable var boldWeight: CGFloat {
        get {
            return font.pointSize
        }
        set {
            font = UIFont(name: "GmarketSansBold", size: newValue)
        }
    }
    
    @IBInspectable var mediumWeight: CGFloat {
        get {
            return font.pointSize
        }
        set {
            font = UIFont(name: "GmarketSansMedium", size: newValue)
        }
    }
    
    @IBInspectable var lightWeight: CGFloat {
        get {
            return font.pointSize
        }
        set {
            font = UIFont(name: "GmarketSansLight", size: newValue)
        }
    }
}
