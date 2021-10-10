//
//  UIView.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/25.
//

import UIKit

extension UIView {
    func asImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func addBorder(borderWidth: CGFloat = 1, borderColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
}


