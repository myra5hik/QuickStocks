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
}

enum DataServiceError: Error {
    case fetcher(description: String)
}

// MARK: - Real implementation

class StockDataService: StocksDataServiceProtocol {
    private let iexCloudService: IexCloudProtocol
    
    init(iexService: IexCloudProtocol) {
        self.iexCloudService = iexService
    }
    
    func provideIndex(_ symbol: Symbol) -> AnyPublisher<Index, DataServiceError> {
        return Just(StubData.indices[0])
            .setFailureType(to: DataServiceError.self)
            .eraseToAnyPublisher()
    }
    
    func provideStock(_ symbol: Symbol) -> AnyPublisher<Stock, DataServiceError> {
        return iexCloudService.fetchStock(symbol)
            .mapError {
                DataServiceError.fetcher(description: $0.localizedDescription)
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
}
