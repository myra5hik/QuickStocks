//
//  CacheManager.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 26.03.2021.
//

import Foundation
import Cache
import Combine
import SwiftUI

protocol CacheManagerStockProtocol {
    func store(stock: Stock) -> Void
    func get(stock: Symbol) -> AnyPublisher<Stock, CacheManagerError>
}

protocol CacheManagerImageProtocol {
    func store(symbol: Symbol, image: UIImage) -> Void
    func get(logoFor symbol: Symbol) -> AnyPublisher<UIImage, CacheManagerError>
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
    
    let imageStorage = MemoryStorage<Symbol, UIImage>(
        config: MemoryConfig(expiry: .seconds(60 * 60), countLimit: 10 * 1024)
    )
    
    let fastQueue = DispatchQueue(label: "CacheManagerFast", qos: .userInitiated)
    let slowQueue = DispatchQueue(label: "CacheManagerSlow", qos: .utility)
}

// MARK: - Stock object caching

extension CacheManager: CacheManagerStockProtocol {
    func store(stock: Stock) -> Void {
        slowQueue.async { [weak stockStorage] in
            stockStorage?.setObject(stock, forKey: stock.id)
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

// MARK: - Image caching

extension CacheManager: CacheManagerImageProtocol {
    func store(symbol: Symbol, image: UIImage) -> Void {
        slowQueue.async { [weak imageStorage] in
            imageStorage?.setObject(image, forKey: symbol)
        }
    }
    
    func get(logoFor symbol: Symbol) -> AnyPublisher<UIImage, CacheManagerError> {
        var rv: UIImage? = nil
        var error: CacheManagerError? = nil
        
        fastQueue.sync { [weak imageStorage] in
            let record = try? imageStorage?.entry(forKey: symbol)
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
