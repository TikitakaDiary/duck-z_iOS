//
//  UITextField.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/09.
//

import UIKit

extension UITextField {
    @IBInspectable var boldWeight: CGFloat {
        get {
            return font?.pointSize ?? 10
        }
        set {
            font = UIFont(name: "GmarketSansBold", size: newValue)
        }
    }
    
    @IBInspectable var mediumWeight: CGFloat {
        get {
            return font?.pointSize ?? 10
        }
        set {
            font = UIFont(name: "GmarketSansMedium", size: newValue)
        }
    }
    
    @IBInspectable var lightWeight: CGFloat {
        get {
            return font?.pointSize ?? 10
        }
        set {
            font = UIFont(name: "GmarketSansLight", size: newValue)
        }
    }
}
