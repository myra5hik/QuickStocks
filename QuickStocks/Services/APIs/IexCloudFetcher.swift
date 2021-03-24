//
//  FinnHubFetcher.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 20.03.2021.
//

import Foundation
import Combine

protocol IexCloudProtocol {
    func fetchStock(_ symbol: Symbol) -> AnyPublisher<Stock, FetcherError>
}

class IexCloudFetcher {
    private let session = URLSession.shared
}

extension IexCloudFetcher: IexCloudProtocol {
    func fetchStock(_ symbol: Symbol) -> AnyPublisher<Stock, FetcherError> {
        guard let url = quoteComponents(for: symbol).url else {
            let error = FetcherError.networking(
                description: "IexCloudFetcher couldn't create URL for \(symbol)"
            )
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error in
                FetcherError.networking(description: error.localizedDescription)
            }
            .map { $0.data }
            .decode(type: Stock.self, decoder: JSONDecoder())
            .mapError { error in
                FetcherError.parsing(description: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - iexCloud REST API

private extension IexCloudFetcher {
    struct Components {
        static let scheme = "https"
        static let host = "cloud.iexapis.com"
        static let rootPath = "/v1"
        static let auth = "pk_83e37c70d33641e49bde944279f6b920"
    }
    
    func quoteComponents(for symbol: Symbol) -> URLComponents {
        var rv = URLComponents()
        rv.scheme = IexCloudFetcher.Components.scheme
        rv.host = IexCloudFetcher.Components.host
        rv.path = IexCloudFetcher.Components.rootPath + "/stock/" + symbol + "/quote"
        rv.queryItems = [
            URLQueryItem(name: "token", value: IexCloudFetcher.Components.auth)
        ]
        return rv
    }
    
    func quoteComponents(for symbols: [Symbol]) -> URLComponents {
        var rv = URLComponents()
        rv.scheme = IexCloudFetcher.Components.scheme
        rv.host = IexCloudFetcher.Components.host
        rv.path = String(
            IexCloudFetcher.Components.rootPath + "/stock/market/batch"
        )
        rv.queryItems = [
            URLQueryItem(name: "symbols", value: symbols.joined(separator: ",")),
            URLQueryItem(name: "types", value: "quote"),
            URLQueryItem(name: "token", value: IexCloudFetcher.Components.auth)
        ]
        return rv
    }
}
