//
//  Stock.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 18.03.2021.
//

import Foundation

struct Stock {
    let symbol: String
    let name: String
    let currency: String
    let logo: URL?
}

extension Stock {
    struct Quote {
        let current: Double
        let high: Double
        let low: Double
        let open: Double
        let previousClose: Double
    }
}

extension Stock {
    struct Profile {
        let country: String
        let exchange: String
    }
}

// MARK: - Helpers

extension Stock: Identifiable {
    var id: String { symbol }
}
