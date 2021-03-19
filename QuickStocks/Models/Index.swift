//
//  Index.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import Foundation

struct Index {
    let symbol: Symbol
    let constituents: [Symbol]
}

extension Index: Identifiable {
    var id: Symbol { symbol }
}
