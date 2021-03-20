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
        StockListView()
    }
}

// MARK: - ViewModel

extension IndexView {
    class ViewModel: ObservableObject {
        @Published private(set) var list: [Stock]
        
        private let indexSymbol: Symbol
        
        private let container: DIContainer
        
        init(container: DIContainer, indexSymbol: Symbol) {
            self.container = container
            self.indexSymbol = indexSymbol
            self.list = []
        }
    }
}

// MARK: - Preview

struct IndexView_Previews: PreviewProvider {
    static var previews: some View {
        IndexView(
            viewModel: .init(
                container: DIContainer.stub,
                indexSymbol: "^GSPC"
            )
        )
    }
}
