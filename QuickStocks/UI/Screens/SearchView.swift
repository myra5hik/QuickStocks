//
//  SearchView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 23.03.2021.
//

import SwiftUI
import Combine

struct SearchView: View {
    @ObservedObject private(set) var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                searchBar
                listView
            }
        }
    }
}

private extension SearchView {
    var searchBar: some View {
        SearchBarView(
            viewModel: .init(container: viewModel.container, publisher: nil)
        ).padding()
    }
    
    var listView: some View {
        StockListView(
            viewModel: .init(container: viewModel.container, stockSymbols: viewModel.list)
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Search").h2()
            }
        }
    }
}

// MARK: - ViewModel

extension SearchView {
    class ViewModel: ObservableObject {
        @Published var searched: String = ""
        @Published var list: [Symbol] = []
        
        let container: DIContainer
        private var bag: Set<AnyCancellable>
        
        init(container: DIContainer) {
            self.container = container
            self.bag = .init()
        }
    }
}

// MARK: - Preview

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(viewModel: .init(container: DIContainer.stub))
    }
}
