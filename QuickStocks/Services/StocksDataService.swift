//
//  StocksDataService.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import Foundation
import Combine

protocol StocksDataServiceProtocol {
    func provideIndex(_ symbol: Symbol) -> AnyPublisher<Index, Error>
    func provideStock(_ symbol: Symbol) -> AnyPublisher<Stock, Error>
    func provideStocks(_ symbols: [Symbol]) -> AnyPublisher<[Stock], Error>
}

enum DataServiceError: Error {
    case network
    case parsing
}

class StubStockDataService: StocksDataServiceProtocol {
    func provideIndex(_ symbol: Symbol) -> AnyPublisher<Index, Error> {
        switch symbol {
        case "Index1":
            let output = Index(
                symbol: "Index1",
                constituents: ["AAPL", "YNDX"]
            )
            return Just(output)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case "Index2":
            let output = Index(
                symbol: "Index2",
                constituents: ["TSLA"]
            )
            return Just(output)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        default:
            return Fail(error: DataServiceError.network)
                .eraseToAnyPublisher()
        }
    }
    
    func provideStock(_ symbol: Symbol) -> AnyPublisher<Stock, Error> {
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
    
    func provideStocks(_ symbols: [Symbol]) -> AnyPublisher<[Stock], Error> {
        let stocks = [
            "AAPL": Stock(symbol: "AAPL", name: "Apple Inc.", currency: "USD", logo: nil),
            "YNDX": Stock(symbol: "YNDX", name: "Yandex LLC", currency: "RUB", logo: nil),
            "TSLA": Stock(symbol: "TSLA", name: "Tesla Inc.", currency: "USD", logo: nil)
        ]
        
        let output = symbols.compactMap { stocks[$0] }
        
        return Just(output)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
