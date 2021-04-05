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

///
/// Provides acces to a URLSession, which makes requests no more often than the specified amount of times per second.
///
class ThrottledURLSession {
    private let session: URLSession
    /// Stores minimal interval, at which the session can be accessed. Defined at initialization.
    private let interval: TimeInterval
    /// Stores earliest point in time, when session can be accessed. Written to by assignSeat().
    private var nextSeat: Date
    private let scheduler = DispatchQueue(label: "ThrottledURLSession", qos: .utility)
    
    init(config: URLSessionConfiguration = configureDefaultSession(), maxPerSecond: Double) {
        self.session = URLSession(configuration: config)
        self.interval = 1 / maxPerSecond
        self.nextSeat = Date() + interval
    }
}

// MARK: - ThrottledURLSessionProtocol implementation

extension ThrottledURLSession: ThrottledURLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError> {
        let requestDelay = assignSeatAndReturnDelay()
        return delayedPublisher(delay: requestDelay)
            .flatMap { [session] (_) in
                session.dataTaskPublisher(for: request)
            }
            .eraseToAnyPublisher()
    }
    
    func dataTaskPublisher(for url: URL) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError> {
        let requestDelay = assignSeatAndReturnDelay()
        return delayedPublisher(delay: requestDelay)
            .flatMap { [session] (_) -> URLSession.DataTaskPublisher in
                session.dataTaskPublisher(for: url)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Private

private extension ThrottledURLSession {
    /// Reserves the closest available seat to access the session, and returns the delay, by which the request should be held back.
    /// If current time is later than the stored nextSeat, returns zero delay.
    /// Writes to the nextSeat variable, by advancing it by instance's configured interval.
    func assignSeatAndReturnDelay() -> TimeInterval {
        let now = Date()
        if now >= nextSeat { nextSeat = now }
        let requestDelay = nextSeat.timeIntervalSince(now)
        self.nextSeat = self.nextSeat.addingTimeInterval(self.interval)
        return requestDelay
    }
    
    /// Returns a publisher, which will fire after specified delay.
    func delayedPublisher(delay: TimeInterval) -> AnyPublisher<Void?, Never> {
        return Future<Void?, Never> { promise in
            promise(.success(nil))
        }
        .delay(for: .seconds(delay), scheduler: scheduler)
        .eraseToAnyPublisher()
    }
}

// MARK: - Default session configuration

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
