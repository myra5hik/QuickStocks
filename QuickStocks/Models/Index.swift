//
//  Index.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import Foundation

struct Index: Decodable {
    let symbol: Symbol
    let constituents: [Symbol]
    
    var name: String { return SupportedIndices.name(for: self.symbol) ?? self.symbol }
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case constituents
    }
}

extension Index: Identifiable {
    var id: Symbol { symbol }
}

extension Index: Equatable {
    static func ==(lhs: Index, rhs: Index) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func !=(lhs: Index, rhs: Index) -> Bool {
        return lhs.id != rhs.id
    }
}
