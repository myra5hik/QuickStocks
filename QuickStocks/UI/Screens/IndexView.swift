//
//  IndexView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import SwiftUI

struct IndexView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        StockListView(
            viewModel: .init(
                container: self.viewModel.container,
                stockSymbols: self.viewModel.index?.constituents ?? []
            )
        )
    }
}

// MARK: - ViewModel

extension IndexView {
    class ViewModel: ObservableObject {
        @Published private(set) var index: Index?
        
        let container: DIContainer
        private let indexSymbol: Symbol
        
        init(container: DIContainer, indexSymbol: Symbol) {
            self.container = container
            self.indexSymbol = indexSymbol
            self.index = nil
        }
    }
}

// MARK: - Preview

fileprivate extension IndexView.ViewModel {
    convenience init() {
        self.init(container: DIContainer.stub, indexSymbol: "")
        self.index = Index(
            symbol: "^GSPC",
            constituents: ["AAPL", "YNDX", "TSLA"]
        )
    }
}

struct IndexView_Previews: PreviewProvider {
    static var previews: some View {
        IndexView(viewModel: IndexView.ViewModel.init())
    }
}
