//
//  ThrottledURLSession.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 05.04.2021.
//

import Foundation
import Combine

protocol ThrottledURLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError>
}

class ThrottledURLSession {
    private let session: URLSession
    private let interval: TimeInterval
    private var nextSeat: Date
    private let scheduler = DispatchQueue(label: "ThrottledURLSession", qos: .utility)
    
    init(config: URLSessionConfiguration = configureDefaultSession(), maxPerSecond: Double) {
        self.session = URLSession(configuration: config)
        self.interval = 1 / maxPerSecond
        self.nextSeat = Date() + interval
    }
}

extension ThrottledURLSession: ThrottledURLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError> {
        let now = Date()
        if now >= nextSeat { nextSeat = now }
        let requestDelay = nextSeat.timeIntervalSince(now)
        self.nextSeat = self.nextSeat.addingTimeInterval(self.interval)
        
        return Future<Void?, Never> { promise in
            promise(.success(nil))
        }
        .delay(for: .seconds(requestDelay), scheduler: scheduler)
        .flatMap { [session] (_) in
            session.dataTaskPublisher(for: request)
        }
        .eraseToAnyPublisher()
    }
}

private extension ThrottledURLSession {
    static func configureDefaultSession() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.httpMaximumConnectionsPerHost = 2
        config.httpShouldUsePipelining = true
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 10
        return config
    }
}
