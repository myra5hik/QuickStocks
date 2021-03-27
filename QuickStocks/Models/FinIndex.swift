//
//  FinIndex.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import Foundation

struct FinIndex: Decodable {
    let symbol: Symbol
    let constituents: [Symbol]
    
    var name: String { return SupportedIndices.name(for: self.symbol) ?? self.symbol }
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case constituents
    }
}

extension FinIndex: Identifiable {
    var id: Symbol { symbol }
}

extension FinIndex: Equatable {
    static func ==(lhs: FinIndex, rhs: FinIndex) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func !=(lhs: FinIndex, rhs: FinIndex) -> Bool {
        return lhs.id != rhs.id
    }
}
