//
//  StockListView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import SwiftUI

struct StockListView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            
        }
    }
}

// MARK: - ViewModel

extension StockListView {
    class ViewModel: ObservableObject {
        @Published var list: [Stock]
        let container: DIContainer
        
        init(container: DIContainer) {
            self.container = container
            self.list = []
        }
    }
}

// MARK: - Preview

struct StockListView_Previews: PreviewProvider {
    static var previews: some View {
        StockListView(viewModel: .init(container: DIContainer.stub))
    }
}
