//
//  Stock.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 18.03.2021.
//

import Foundation

struct Stock: Codable {
    let symbol: Symbol
    let name: String
    let exchange: String
    
    let current: Double?
    let high: Double?
    let low: Double?
    let open: Double?
    let close: Double?
    let previousClose: Double?
    let changeAbsolute: Double?
    let changePercent: Double?
    
    let week52High: Double?
    let week52Low: Double?
    let peRatio: Double?
    let ytdChange: Double?
    let marketCap: Double?
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case name = "companyName"
        case exchange = "primaryExchange"
        
        case current = "latestPrice"
        case high
        case low
        case open
        case close
        case previousClose
        case changeAbsolute = "change"
        case changePercent
        
        case week52High
        case week52Low
        case peRatio
        case ytdChange
        case marketCap
    }
}

// MARK: - Helpers

extension Stock: Identifiable {
    var id: Symbol { symbol }
}
