//
//  Loadable.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 27.03.2021.
//

import Foundation

enum Loadable<T> {
    case newborn
    case loading
    case loaded(T)
    case errorLoading(description: String)
}
