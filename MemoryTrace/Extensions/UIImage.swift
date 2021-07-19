//
//  UIImage.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/07/19.
//

import UIKit

extension UIImage {
    func resizedImage(targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
