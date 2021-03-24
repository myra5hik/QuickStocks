//
//  HardCodedData.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 24.03.2021.
//

import Foundation

// MARK: - Supported financial indices

/*
 The Finnhub API does not support retreiving list of available indices,
 neither it doesn't support receiving name of the index with index symbol,
 thus the list is hard-coded into the app.
 https://finnhub.io/docs/api/indices-constituents
 */

struct SupportedIndices {
    static var list: [Symbol] {
        SupportedIndices.dictionary.keys.reduce(into: [Symbol]()) { (curr, new) in
            curr.append(new)
        }
    }
    
    static func name(for indexSymbol: Symbol) -> String? {
        return SupportedIndices.dictionary[indexSymbol]
    }
}

private extension SupportedIndices {
    static let dictionary: [Symbol: String] = [
        "^GSPC": "S&P 500",
        "^NDX": "Nasdaq 100",
        "^DJI": "Dow Jones"
    ]
}
