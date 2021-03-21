//
//  StubData.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 21.03.2021.
//

import Foundation

struct StubData {
    static let indices = [
        Index(symbol: "Index1", constituents: ["AAPL", "YNDX", "TSLA"])
    ]
    
    static let stocks = [
        Stock(
            symbol: "AAPL",
            name: "Apple inc.",
            exchange: "NYSE",
            
            current: 100,
            high: 105,
            low: 95,
            open: 90,
            close: 90,
            previousClose: 85,
            changeAbsolute: 100 - 85,
            changePercent: 100 / 85,
            week52High: 120,
            week52Low: 73,
            peRatio: 15,
            ytdChange: 0.35,
            marketCap: 1_000_000_000
        ),
        Stock(
            symbol: "YNDX",
            name: "Yandex LLC",
            exchange: "Moscow Exchange",
            
            current: 100,
            high: 105,
            low: 95,
            open: 90,
            close: 90,
            previousClose: 85,
            changeAbsolute: 100 - 85,
            changePercent: 100 / 85,
            week52High: 120,
            week52Low: 73,
            peRatio: 15,
            ytdChange: 0.35,
            marketCap: 1_000_000_000
        )
    ]
}
