//
//  CacheManager.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 26.03.2021.
//

import Foundation
import Cache
import Combine

protocol CacheManagerProtocol {
    func store(stock: Stock) -> Void
    func get(stock: Symbol) -> AnyPublisher<Stock, CacheManagerError>
}

enum CacheManagerError: Error {
    case notFound
    case expired
    case managerFailed
}

class CacheManager {
    let stockStorage = MemoryStorage<Symbol, Stock>(
        config: MemoryConfig(expiry: .seconds(60), countLimit: 10 * 1024)
    )
    
    let fastQueue = DispatchQueue(label: "CacheManagerFast", qos: .userInitiated)
    let slowQueue = DispatchQueue(label: "CacheManagerSlow", qos: .utility)
}

extension CacheManager: CacheManagerProtocol {
    func store(stock: Stock) -> Void {
        slowQueue.async { [weak self] in
            self?.stockStorage.setObject(stock, forKey: stock.id)
        }
    }
    
    func get(stock: Symbol) -> AnyPublisher<Stock, CacheManagerError> {
        var rv: Stock? = nil
        var error: CacheManagerError? = nil
        
        fastQueue.sync { [weak self] in
            let record = try? self?.stockStorage.entry(forKey: stock)
            if record == nil { error = .notFound; return }
            if record!.expiry.isExpired { error = .expired; return }
            rv = record!.object
        }
        
        if error != nil {
            return Fail(error: error!).eraseToAnyPublisher()
        } else {
            assert(rv != nil)
            return Just(rv!).setFailureType(to: CacheManagerError.self).eraseToAnyPublisher()
        }
    }
}
