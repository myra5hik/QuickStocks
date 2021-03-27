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
    func provideIndex(_ symbol: Symbol) -> AnyPublisher<FinIndex, DataServiceError>
    func provideStock(_ symbol: Symbol) -> AnyPublisher<Stock, DataServiceError>
    func searchStock(_ query: String) -> AnyPublisher<[Symbol], DataServiceError>
    func provideLogo(_ stock: Symbol) -> AnyPublisher<Image, DataServiceError>
}

enum DataServiceError: Error {
    case fetcher(description: String)
}

// MARK: - Real implementation

class StockDataService: StocksDataServiceProtocol {
    private let iexCloudFetcher: IexCloudProtocol
    private let finnhubFetcher: FinnHubProtocol
    private let cacheManager: CacheManagerProtocol
    
    init(
        iexFetcher: IexCloudProtocol, finnhubFetcher: FinnHubProtocol,
        cacheManager: CacheManagerProtocol
    ) {
        self.iexCloudFetcher = iexFetcher
        self.finnhubFetcher = finnhubFetcher
        self.cacheManager = cacheManager
    }
    
    func provideIndex(_ symbol: Symbol) -> AnyPublisher<FinIndex, DataServiceError> {
        return finnhubFetcher.fetchIndex(symbol)
            .mapError { (error) -> DataServiceError in
                DataServiceError.fetcher(description: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func provideStock(_ symbol: Symbol) -> AnyPublisher<Stock, DataServiceError> {
        let fetchTask = iexCloudFetcher.fetchStock(symbol)
            .mapError {
                DataServiceError.fetcher(description: $0.localizedDescription)
            }
            .map { [weak self] (stock) -> Stock in
                self?.cacheManager.store(stock: stock)
                return stock
            }
            .eraseToAnyPublisher()
        
        let cacheTask = cacheManager.get(stock: symbol)
            .catch { (_) -> AnyPublisher<Stock, DataServiceError> in
                fetchTask
            }
            .eraseToAnyPublisher()
        
        return cacheTask
    }
    
    func searchStock(_ query: String) -> AnyPublisher<[Symbol], DataServiceError> {
        guard query != "" else {
            return Just([])
                .setFailureType(to: DataServiceError.self)
                .eraseToAnyPublisher()
        }
        
        return finnhubFetcher.searchSymbol(query)
            .mapError { (error) -> DataServiceError in
                DataServiceError.fetcher(description: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func provideLogo(_ stock: Symbol) -> AnyPublisher<Image, DataServiceError> {
        return iexCloudFetcher.fetchImage(stock)
            .mapError { (error) -> DataServiceError in
                DataServiceError.fetcher(description: "")
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Stub implementation

class StubStockDataService: StocksDataServiceProtocol {
    func provideIndex(_ symbol: Symbol) -> AnyPublisher<FinIndex, DataServiceError> {
        return Just(StubData.indices[0])
            .setFailureType(to: DataServiceError.self)
            .eraseToAnyPublisher()
    }
    
    func provideStock(_ symbol: Symbol) -> AnyPublisher<Stock, DataServiceError> {
        return Just(StubData.stocks[0])
            .setFailureType(to: DataServiceError.self)
            .eraseToAnyPublisher()
    }
    
    func searchStock(_ query: String) -> AnyPublisher<[Symbol], DataServiceError> {
        return Just(["AAPL", "AAPL.SW", "APC.BE"])
            .setFailureType(to: DataServiceError.self)
            .eraseToAnyPublisher()
    }
    
    func provideLogo(_ stock: Symbol) -> AnyPublisher<Image, DataServiceError> {
        return Just(Image("YNDX"))
            .setFailureType(to: DataServiceError.self)
            .eraseToAnyPublisher()
    }
}
