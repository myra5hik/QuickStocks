//
//  StocksDataService.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import Foundation
import Combine
import SwiftUI

protocol StocksDataServiceProtocol {
    func provideIndex(_ symbol: Symbol) -> AnyPublisher<FinIndex, FetcherError>
    func provideStock(_ symbol: Symbol) -> AnyPublisher<Stock, FetcherError>
    func searchStock(_ query: String) -> AnyPublisher<[Symbol], FetcherError>
    func provideLogo(_ stock: Symbol) -> AnyPublisher<UIImage, FetcherError>
}

// MARK: - Real implementation

///
/// StockDataService is designed to be the single point of contatct for all views,
/// managing caching and network requests without exposing this logic outside.
///
class StockDataService: StocksDataServiceProtocol {
    private let iexCloudFetcher: IexCloudProtocol
    private let finnhubFetcher: FinnHubProtocol
    private let cacheManager: CacheManagerStockProtocol & CacheManagerImageProtocol
    
    init(
        iexFetcher: IexCloudProtocol, finnhubFetcher: FinnHubProtocol,
        cacheManager: CacheManagerStockProtocol & CacheManagerImageProtocol
    ) {
        self.iexCloudFetcher = iexFetcher
        self.finnhubFetcher = finnhubFetcher
        self.cacheManager = cacheManager
    }
    
    func provideIndex(_ symbol: Symbol) -> AnyPublisher<FinIndex, FetcherError> {
        return finnhubFetcher.fetchIndex(symbol)
            .eraseToAnyPublisher()
    }
    
    func provideStock(_ symbol: Symbol) -> AnyPublisher<Stock, FetcherError> {
        let fetchTask = iexCloudFetcher.fetchStock(symbol)
            .handleEvents(receiveOutput: { [weak self] (stock) in
                self?.cacheManager.store(stock: stock)
            })
            .eraseToAnyPublisher()
        
        let cacheTask = cacheManager.get(stock: symbol)
            .catch { (_) -> AnyPublisher<Stock, FetcherError> in
                fetchTask
            }
            .eraseToAnyPublisher()
        
        return cacheTask
    }
    
    func searchStock(_ query: String) -> AnyPublisher<[Symbol], FetcherError> {
        guard query != "" else {
            return Just([])
                .setFailureType(to: FetcherError.self)
                .eraseToAnyPublisher()
        }
        
        return finnhubFetcher.searchSymbol(query)
            .eraseToAnyPublisher()
    }
    
    func provideLogo(_ stock: Symbol) -> AnyPublisher<UIImage, FetcherError> {
        // If logo is stored in the app's bundle, returns the stored one.
        // Overriding manually, mainly because the chosen API returns a strange
        // image for "YNDX". :)
        if let uiImage = UIImage(named: stock) {
            return Just(uiImage).setFailureType(to: FetcherError.self).eraseToAnyPublisher()
        }
        
        let fetchTask = iexCloudFetcher.fetchImage(stock)
            .handleEvents(receiveOutput: { [weak self] (uiImage) in
                self?.cacheManager.store(symbol: stock, image: uiImage)
            })
            .eraseToAnyPublisher()
        
        let cacheTask = cacheManager.get(logoFor: stock)
            .catch { (_) -> AnyPublisher<UIImage, FetcherError> in
                fetchTask
            }
            .eraseToAnyPublisher()
        
        return cacheTask
    }
}

// MARK: - Stub implementation

class StubStockDataService: StocksDataServiceProtocol {
    func provideIndex(_ symbol: Symbol) -> AnyPublisher<FinIndex, FetcherError> {
        return Just(StubData.indices[0])
            .setFailureType(to: FetcherError.self)
            .eraseToAnyPublisher()
    }
    
    func provideStock(_ symbol: Symbol) -> AnyPublisher<Stock, FetcherError> {
        return Just(StubData.stocks[0])
            .setFailureType(to: FetcherError.self)
            .eraseToAnyPublisher()
    }
    
    func searchStock(_ query: String) -> AnyPublisher<[Symbol], FetcherError> {
        return Just(["AAPL", "AAPL.SW", "APC.BE"])
            .setFailureType(to: FetcherError.self)
            .eraseToAnyPublisher()
    }
    
    func provideLogo(_ stock: Symbol) -> AnyPublisher<UIImage, FetcherError> {
        return Just(UIImage(named: "YNDX")!)
            .setFailureType(to: FetcherError.self)
            .eraseToAnyPublisher()
    }
}
