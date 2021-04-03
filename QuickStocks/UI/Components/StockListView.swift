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
            LazyVStack(spacing: 0.0) {
                ForEach(viewModel.rowViewModels) { rowViewModel in
                    StockListRowView(model: rowViewModel)
                    .padding(.horizontal, 16.0)
                }
            }
            .animation(.easeInOut(duration: 0.15))
        }
    }
}

// MARK: - ViewModel

extension StockListView {
    class ViewModel: ObservableObject {
        @Published private(set) var rowViewModels: [StockListRowView.ViewModel]
        
        let container: DIContainer
        private var disposables = Set<AnyCancellable>()
        
        init(container: DIContainer, stockSymbols: AnyPublisher<[Symbol], Never>) {
            self.container = container
            self.rowViewModels = []
            
            subscribeToList(publisher: stockSymbols)
        }
    }
}

private extension StockListView.ViewModel {
    func subscribeToList(publisher: AnyPublisher<[Symbol], Never>) -> Void {
        publisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (updatedList) in
                guard let self = self else { return }
                guard !updatedList.isEmpty else { self.rowViewModels = []; return }
                
                var newList = [StockListRowView.ViewModel]()
                var counter = 1
                let loaded = [Symbol: StockListRowView.ViewModel](
                    // Capturing loaded rows' view models, so they don't refresh
                    uniqueKeysWithValues: self.rowViewModels.map { ($0.id, $0) }
                )
                
                for stockSymbol in updatedList {
                    if let loaded = loaded[stockSymbol] {
                        newList.append(loaded)
                        newList.last!.isOdd = (counter % 2 == 1)
                    } else {
                        newList.append(
                            StockListRowView.ViewModel(
                                container: self.container,
                                stockSymbol: stockSymbol, isOdd: counter % 2 == 1
                            )
                        )
                    }
                    counter += 1
                }
                
                self.rowViewModels = newList
            }
            .store(in: &disposables)
    }
}

// MARK: - Preview

fileprivate extension StockListView.ViewModel {
    convenience init() {
        self.init(container: DIContainer.stub, stockSymbols: Just([]).eraseToAnyPublisher())
        self.rowViewModels = StubData.stocks.map { (stock) -> StockListRowView.ViewModel in
            .init(container: DIContainer.stub, stockSymbol: stock.symbol, isOdd: false)
        }
    }
}

struct StockListView_Previews: PreviewProvider {
    static var previews: some View {
        StockListView(viewModel: StockListView.ViewModel.init())
            .previewLayout(.fixed(width: 300, height: 500))
    }
}
