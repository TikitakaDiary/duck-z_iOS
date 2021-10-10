//
//  NetworkError.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/10/05.
//

import Foundation

enum NetworkError: Error {
    case network
    case unknown
    case decodingFail
    
    var description: String {
        switch self {
        case .network:
            return "네트워크 연결을 확인해주세요"
        case .unknown:
            return "오류가 발생했습니다."
        case .decodingFail:
            return "디코딩 실패"
        }
    }
}
