//
//  BackgroundColor.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/26.
//

import UIKit

enum BackgroundColor: Int {
    case color0 = 0
    case color1
    case color2
    case color3
    case color4
    case color5
    case color6
    case color7
    case color8
    case color9
    case color10
    case color11
    
    var color: UIColor {
        switch self {
        case .color0:
            return UIColor(red: 213/255, green: 78/255, blue: 78/255, alpha: 1)
        case .color1:
            return UIColor(red: 245/255, green: 151/255, blue: 40/255, alpha: 1)
        case .color2:
            return UIColor(red: 246/255, green: 206/255, blue: 41/255, alpha: 1)
        case .color3:
            return UIColor(red: 104/255, green: 195/255, blue: 89/255, alpha: 1)
        case .color4:
            return UIColor(red: 67/255, green: 202/255, blue: 194/255, alpha: 1)
        case .color5:
            return UIColor(red: 53/255, green: 120/255, blue: 220/255, alpha: 1)
        case .color6:
            return UIColor(red: 42/255, green: 67/255, blue: 199/255, alpha: 1)
        case .color7:
            return UIColor(red: 139/255, green: 71/255, blue: 208/255, alpha: 1)
        case .color8:
            return UIColor(red: 234/255, green: 122/255, blue: 166/255, alpha: 1)
        case .color9:
            return UIColor(red: 177/255, green: 177/255, blue: 177/255, alpha: 1)
        case .color10:
            return UIColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1)
        case .color11:
            return UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1)
        }
    }
}
