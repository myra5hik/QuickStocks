//
//  FinnHubFetcher.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 24.03.2021.
//

import Foundation
import Combine

protocol FinnHubProtocol {
    func fetchIndex(_ symbol: Symbol) -> AnyPublisher<FinIndex, FetcherError>
    func searchSymbol(_ query: String) -> AnyPublisher<[Symbol], FetcherError>
    func fetchHistoricPrices(_ stockSymbol: Symbol) -> AnyPublisher<[Double], FetcherError>
}

class FinnHubFetcher {
    private let session = URLSession.shared
}

extension FinnHubFetcher: FinnHubProtocol {
    func fetchIndex(_ symbol: Symbol) -> AnyPublisher<FinIndex, FetcherError> {
        guard let url = indexComponents(for: symbol).url else {
            return Fail(
                error: FetcherError.networking(description: "FinnhubFetcher couldn't create URL for \(symbol)")
            ).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { (error) -> FetcherError in
                FetcherError.networking(description: error.localizedDescription)
            }
            .map { $0.data }
            .decode(type: FinIndex.self, decoder: JSONDecoder())
            .mapError { _ in FetcherError.parsing }
            .eraseToAnyPublisher()
    }
    
    func searchSymbol(_ query: String) -> AnyPublisher<[Symbol], FetcherError> {
        guard let url = searchComponents(query: query).url else {
            return Fail(
                error: FetcherError.networking(description: "FinnhubFetcher couldn't create URL for \(query)")
            ).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { (error) -> FetcherError in
                FetcherError.networking(description: error.localizedDescription)
            }
            .map { $0.data }
            .decode(type: ResponseFinnhubSymbolLookup.self, decoder: JSONDecoder())
            .mapError { _ in return FetcherError.parsing }
            .map { (response) -> [Symbol] in
                response.result.map { $0.symbol }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchHistoricPrices(_ stockSymbol: Symbol) -> AnyPublisher<[Double], FetcherError> {
        guard let url = candlesComponents(for: stockSymbol).url else {
            return Fail(
                error: FetcherError.networking(
                    description: "FinnhubFetcher couldn't create URL for \(stockSymbol)'s candles request"
                )
            ).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { (error) -> FetcherError in
                FetcherError.networking(description: error.localizedDescription)
            }
            .map { $0.data }
            .decode(type: ResponseFinnhubCandles.self, decoder: JSONDecoder())
            .mapError { _ in return FetcherError.parsing }
            .map { (response) -> [Double] in
                return response.c
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - finnhub.io REST API

private extension FinnHubFetcher {
    struct Components {
        static let scheme = "https"
        static let host = "finnhub.io"
        static let rootPath = "/api/v1"
        static let auth = "c1b5bvv48v6rcdq9u6g0"
    }
    
    //
    // https://finnhub.io/docs/api/indices-constituents
    //
    func indexComponents(for symbol: Symbol) -> URLComponents {
        var rv = URLComponents()
        rv.scheme = FinnHubFetcher.Components.scheme
        rv.host = FinnHubFetcher.Components.host
        rv.path = FinnHubFetcher.Components.rootPath + "/index/constituents"
        rv.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "token", value: FinnHubFetcher.Components.auth)
        ]
        return rv
    }
    
    //
    // https://finnhub.io/docs/api/symbol-search
    //
    func searchComponents(query: String) -> URLComponents {
        var rv = URLComponents()
        rv.scheme = FinnHubFetcher.Components.scheme
        rv.host = FinnHubFetcher.Components.host
        rv.path = FinnHubFetcher.Components.rootPath + "/search"
        rv.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "token", value: FinnHubFetcher.Components.auth)
        ]
        return rv
    }
    
    //
    // https://finnhub.io/docs/api/stock-candles
    //
    func candlesComponents(for symbol: Symbol) -> URLComponents {
        var rv = URLComponents()
        
        // TODO: Customizable time frame instead of hard-coded last 6mo
        let from = String(String(Date().advanced(by: -86400 * 365).timeIntervalSince1970.rounded(.down)).dropLast(2))
        let to = String(String(Date().timeIntervalSince1970.rounded(.down)).dropLast(2))
        
        rv.scheme = FinnHubFetcher.Components.scheme
        rv.host = FinnHubFetcher.Components.host
        rv.path = FinnHubFetcher.Components.rootPath + "/stock/candle"
        rv.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "from", value: from),
            URLQueryItem(name: "to", value: to),
            URLQueryItem(name: "resolution", value: "D"),
            URLQueryItem(name: "token", value: FinnHubFetcher.Components.auth)
        ]
        return rv
    }
}
