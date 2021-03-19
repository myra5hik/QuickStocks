//
//  StocksDataService.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import Foundation
import Combine

protocol StocksDataServiceProtocol {
    func fetchIndex(_ symbol: Symbol) -> AnyPublisher<Index, Error>
    func fetchStock(_ symbol: Symbol) -> AnyPublisher<Stock, Error>
}

enum DataServiceError: Error {
    case network
    case parsing
}

class StubStockDataService: StocksDataServiceProtocol {
    func fetchIndex(_ symbol: Symbol) -> AnyPublisher<Index, Error> {
        let output = Index(
            symbol: "^GSPC",
            constituents: ["AAPL", "YNDX", "TSLA"]
        )
        return Just(output)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchStock(_ symbol: Symbol) -> AnyPublisher<Stock, Error> {
        let output: Stock? = {
            switch symbol {
            case "AAPL": return Stock(symbol: "AAPL", name: "Apple Inc.", currency: "USD", logo: nil)
            case "YNDX": return Stock(symbol: "YNDX", name: "Yandex LLC", currency: "RUB", logo: nil)
            case "TSLA": return Stock(symbol: "TSLA", name: "Tesla Inc.", currency: "USD", logo: nil)
            default: return nil
            }
        }()
        if output != nil {
            return Just(output!)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail<Stock, Error>(error: DataServiceError.network)
                .eraseToAnyPublisher()
        }
    }
}
