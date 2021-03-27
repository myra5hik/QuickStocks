//
//  FetcherError.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 24.03.2021.
//

import Foundation

enum FetcherError: Error {
    case networking(description: String)
    case parsing(description: String)
    case `internal`
}
