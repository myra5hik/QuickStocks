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
        ScrollView {
            LazyVStack {
                ForEach(Array(viewModel.list.enumerated()), id: \.offset) { index, element in
                    StockListRowView(
                        model: .init(
                            container: viewModel.container,
                            stock: element, isOdd: index % 2 == 1
                        )
                    )
                }
            }
        }
        .padding(.horizontal, 16.0)
        
        // TODO: Remove insets
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
            self.requestData()
        }
        
        func requestData() -> Void {
            for symbol in symbols {
                self.container.services.data
                    .provideStock(symbol)
                    .subscribe(on: DispatchQueue.global())
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
