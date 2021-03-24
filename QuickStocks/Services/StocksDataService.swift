//
//  StocksDataService.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import Foundation
import Combine

protocol StocksDataServiceProtocol {
    func provideIndex(_ symbol: Symbol) -> AnyPublisher<Index, DataServiceError>
    func provideStock(_ symbol: Symbol) -> AnyPublisher<Stock, DataServiceError>
    func searchStock(_ query: String) -> AnyPublisher<[Symbol], DataServiceError>
}

enum DataServiceError: Error {
    case fetcher(description: String)
}

// MARK: - Real implementation

class StockDataService: StocksDataServiceProtocol {
    private let iexCloudFetcher: IexCloudProtocol
    private let finnhubFetcher: FinnHubProtocol
    
    init(iexFetcher: IexCloudProtocol, finnhubFetcher: FinnHubProtocol) {
        self.iexCloudFetcher = iexFetcher
        self.finnhubFetcher = finnhubFetcher
    }
    
    func provideIndex(_ symbol: Symbol) -> AnyPublisher<Index, DataServiceError> {
        return Just(StubData.indices[0])
            .setFailureType(to: DataServiceError.self)
            .eraseToAnyPublisher()
    }
    
    func provideStock(_ symbol: Symbol) -> AnyPublisher<Stock, DataServiceError> {
        return iexCloudFetcher.fetchStock(symbol)
            .mapError {
                DataServiceError.fetcher(description: $0.localizedDescription)
            }
            .eraseToAnyPublisher()
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
}

// MARK: - Stub implementation

class StubStockDataService: StocksDataServiceProtocol {
    func provideIndex(_ symbol: Symbol) -> AnyPublisher<Index, DataServiceError> {
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
}
