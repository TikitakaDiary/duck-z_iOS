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
}


