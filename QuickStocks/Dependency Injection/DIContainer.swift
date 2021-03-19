//
//  DIContainer.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import Foundation

struct DIContainer {
    let services: DIContainer.Services
    
    init(services: DIContainer.Services) {
        self.services = services
    }
}

extension DIContainer {
    struct Services {
        let data: StocksDataServiceProtocol
    }
}
