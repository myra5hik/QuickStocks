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
    func provideLogo(_ stock: Symbol) -> AnyPublisher<UIImage, DataServiceError>
}

enum DataServiceError: Error {
    case fetcher(description: String)
}

// MARK: - Real implementation

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
            .handleEvents(receiveOutput: { [weak self] (stock) in
                self?.cacheManager.store(stock: stock)
            })
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
    
    func provideLogo(_ stock: Symbol) -> AnyPublisher<UIImage, DataServiceError> {
        let fetchTask = iexCloudFetcher.fetchImage(stock)
            .mapError { (error) -> DataServiceError in
                DataServiceError.fetcher(description: "")
            }
            .handleEvents(receiveOutput: { [weak self] (uiImage) in
                self?.cacheManager.store(symbol: stock, image: uiImage)
            })
            .eraseToAnyPublisher()
        
        let cacheTask = cacheManager.get(logoFor: stock)
            .catch { (_) -> AnyPublisher<UIImage, DataServiceError> in
                fetchTask
            }
            .eraseToAnyPublisher()
        
        return cacheTask
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
    
    func provideLogo(_ stock: Symbol) -> AnyPublisher<UIImage, DataServiceError> {
        return Just(UIImage(named: "YNDX")!)
            .setFailureType(to: DataServiceError.self)
            .eraseToAnyPublisher()
    }
}
