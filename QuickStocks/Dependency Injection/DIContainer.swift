//
//  DIContainer.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import Foundation

///
/// Dependency Injector container to be used across View Models.
///
struct DIContainer {
    let appState: AppState
    let services: DIContainer.Services
    
    init(services: DIContainer.Services) {
        self.appState = AppState()
        self.services = services
    }
}

// MARK: - Services

extension DIContainer {
    struct Services {
        let data: StocksDataServiceProtocol
    }
}

// MARK: - Stub

extension DIContainer {
    static let stub = DIContainer(
        services: Services(
            data: StubStockDataService()
        )
    )
}
