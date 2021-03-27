//
//  IexCloudFetcher.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 20.03.2021.
//

import Foundation
import Combine
import SwiftUI

protocol IexCloudProtocol {
    func fetchStock(_ symbol: Symbol) -> AnyPublisher<Stock, FetcherError>
    func fetchImage(_ symbol: Symbol) -> AnyPublisher<Image, FetcherError>
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
    
    func fetchImage(_ symbol: Symbol) -> AnyPublisher<Image, FetcherError> {
        return fetchLogoUrl(for: symbol)
            .flatMap { url in
                self.session.dataTaskPublisher(for: url)
                    .mapError { FetcherError.networking(description: $0.localizedDescription) }
            }
            .mapError { (_) -> FetcherError in
                FetcherError.networking(description: "Couldn't fetch logo for \(symbol)")
            }
            .tryMap { (response) throws -> UIImage in
                if let rv = UIImage(data: response.data) { return rv }
                throw FetcherError.internal
            }
            .mapError { (_) in
                FetcherError.parsing(description: "Couldn't create image from Data")
            }
            .map { (uiImage) -> Image in
                Image(uiImage: uiImage)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Helpers

extension IexCloudFetcher {
    func fetchLogoUrl(for stock: Symbol) -> AnyPublisher<URL, FetcherError> {
        guard let url = logoComponents(for: stock).url else {
            let error = FetcherError.networking(
                description: "IexCloudFetcher couldn't create logo URL for \(stock)"
            )
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { (error) in
                FetcherError.networking(description: error.localizedDescription)
            }
            .map { $0.data }
            .tryMap { (data) -> URL in
                guard
                    let json = try? JSONSerialization.jsonObject(with: data),
                    let dict = json as? [String: String],
                    let value = dict["url"],
                    let logoUrl = URL(string: value)
                else { throw FetcherError.internal }
                return logoUrl
            }
            .mapError{ (error) -> FetcherError in
                FetcherError.parsing(description: "IexCloudFetcher couldn't parse logo URL out of response")
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
    
    //
    // https://iexcloud.io/docs/api/#quote
    //
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
    
    //
    // https://iexcloud.io/docs/api/#batch-requests
    //
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
    
    //
    // https://iexcloud.io/docs/api/#logo
    //
    func logoComponents(for symbol: Symbol) -> URLComponents {
        var rv = URLComponents()
        rv.scheme = IexCloudFetcher.Components.scheme
        rv.host = IexCloudFetcher.Components.host
        rv.path = IexCloudFetcher.Components.rootPath + "/stock/" + symbol + "/logo"
        rv.queryItems = [
            URLQueryItem(name: "token", value: IexCloudFetcher.Components.auth)
        ]
        return rv
    }
}
