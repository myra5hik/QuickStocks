//
//  StockListView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 20.03.2021.
//

import SwiftUI
import Combine

struct StockListView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        List(self.viewModel.list) { stock in
            StockListRowView(stock: stock)
        }
    }
}

// MARK: - ViewModel

extension StockListView {
    class ViewModel: ObservableObject {
        @Published private(set) var list: [Stock]
        
        let container: DIContainer
        private let symbols: [Symbol]
        private var disposables = Set<AnyCancellable>()
        
        init(container: DIContainer, stockSymbols: [Symbol]) {
            self.container = container
            self.symbols = stockSymbols
            self.list = []
            self.refresh()
        }
        
        func refresh() -> Void {
            for symbol in symbols {
                self.container.services.data
                    .provideStock(symbol)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] (value) in
                        guard let self = self else { return }
                        switch value {
                        case .failure(_):
                            self.list = []
                        case .finished:
                            break
                        }
                    } receiveValue: { [weak self] (stock) in
                        guard let self = self else { return }
                        self.list.append(stock)
                    }
                    .store(in: &disposables)
            }
        }
    }
}

// MARK: - Preview

fileprivate extension StockListView.ViewModel {
    convenience init() {
        self.init(container: DIContainer.stub, stockSymbols: [])
        self.list = StubData.stocks
    }
}

struct StockListView_Previews: PreviewProvider {
    static var previews: some View {
        StockListView(viewModel: StockListView.ViewModel.init())
    }
}
