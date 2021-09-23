//
//  CALayer.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/09/15.
//

import UIKit

extension CALayer {
    func addBorder(edges: [UIRectEdge], color: UIColor, width: CGFloat) {
        edges.forEach { edge in
            let border = CALayer()
            switch edge {
            case .top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case .bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case .right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            case .left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor
            self.addSublayer(border)
        }
    }
}
