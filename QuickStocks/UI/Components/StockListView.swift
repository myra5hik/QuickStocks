//
//  StockListView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 20.03.2021.
//

import SwiftUI

struct StockListView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        List(self.viewModel.list) { stock in
            StockListRowView()
        }
    }
}

// MARK: - ViewModel

extension StockListView {
    class ViewModel: ObservableObject {
        @Published var list: [Stock]
        
        private let symbols: [Symbol]
        private let container: DIContainer
        
        init(container: DIContainer, stockSymbols: [Symbol]) {
            self.container = container
            self.symbols = stockSymbols
            self.list = []
        }
    }
}

// MARK: - Preview

fileprivate extension StockListView.ViewModel {
    convenience init() {
        self.init(container: DIContainer.stub, stockSymbols: [])
        self.list = [
            Stock(symbol: "AAPL", name: "Apple Inc.", currency: "USD", logo: nil),
            Stock(symbol: "AAPL", name: "Apple Inc.", currency: "USD", logo: nil),
            Stock(symbol: "AAPL", name: "Apple Inc.", currency: "USD", logo: nil)
        ]
    }
}

struct StockListView_Previews: PreviewProvider {
    static var previews: some View {
        StockListView(viewModel: StockListView.ViewModel.init())
    }
}
