//
//  AppState.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 22.03.2021.
//

import Foundation
import Combine

class AppState {
    @Published var favourites: Set<Symbol>
    
    init() {
        self.favourites = []
    }
}

extension AppState {
    func toggleFav(symbol: Symbol) -> Void {
        if !favourites.insert(symbol).inserted {
            favourites.remove(symbol)
        }
    }
}
