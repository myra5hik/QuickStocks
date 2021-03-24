//
//  FinnhubSymbolLookupResponse.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 24.03.2021.
//

import Foundation

// Constructed with https://app.quicktype.io

struct ResponseFinnhubSymbolLookup: Codable, Equatable {
    let count: Int
    let result: [Result]

    enum CodingKeys: String, CodingKey {
        case count
        case result
    }
}

// MARK: - Result

extension ResponseFinnhubSymbolLookup {
    struct Result: Codable, Equatable {
        let resultDescription: String
        let displaySymbol: String
        let symbol: String
        let type: String

        enum CodingKeys: String, CodingKey {
            case resultDescription
            case displaySymbol
            case symbol
            case type
        }
    }
}
