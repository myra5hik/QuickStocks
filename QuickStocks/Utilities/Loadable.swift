//
//  Loadable.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 27.03.2021.
//

import Foundation

///
/// Loadable utility helps keep track and manipulate states of views, which require remote data.
///
enum Loadable<T> {
    case idle
    case loading
    case loaded(T)
    case errorLoading
}
