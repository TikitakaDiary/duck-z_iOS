//
//  String.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/05/30.
//

import Foundation

enum DateType {
    case yearMonth
    case yearMonthDay
}

extension String{
    // regex 대신, string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 사용해도 됨
    func getArrayAfterRegex(regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))

            return results.map {
                guard let range = Range($0.range, in: self) else { return "" }
                
                return String(self[range])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func date(type: DateType) -> String {
        let dateComponent = self.split(separator: "-")
        let year = dateComponent[0]
        let month = dateComponent[1]
        let day = dateComponent[2].split(separator: " ")[0]
        
        switch type {
        case .yearMonth:
            return "\(year).\(month)"
        case .yearMonthDay:
            return "\(year)년 \(month)월 \(day)일"
        }
    }
}
