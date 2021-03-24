//
//  FinnHubFetcher.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 24.03.2021.
//

import Foundation
import Combine

protocol FinnHubProtocol {
    func fetchIndex(_ symbol: Symbol) -> AnyPublisher<Index, FetcherError>
}

class FinnHubFetcher {
    private let session = URLSession.shared
}

extension FinnHubFetcher: FinnHubProtocol {
    func fetchIndex(_ symbol: Symbol) -> AnyPublisher<Index, FetcherError> {
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
            .decode(type: Index.self, decoder: JSONDecoder())
            .mapError { (error) -> FetcherError in
                FetcherError.parsing(description: error.localizedDescription)
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
}
