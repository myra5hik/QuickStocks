//
//  FinnhubCandleResponse.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 04.04.2021.
//

import Foundation

// Constructed with https://app.quicktype.io

struct ResponseFinnhubCandles: Codable, Equatable {
    let c: [Double]
    let h: [Double]
    let l: [Double]
    let o: [Double]
    let s: String
    let t: [Int]
    let v: [Int]

    enum CodingKeys: String, CodingKey {
        case c
        case h
        case l
        case o
        case s
        case t
        case v
    }
}
