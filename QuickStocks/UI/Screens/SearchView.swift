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
        SearchBarView(input: $viewModel.searched).padding()
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
            subscribeToData()
        }
    }
}

private extension SearchView.ViewModel {
    func subscribeToData() -> Void {
        $searched
            .debounce(for: 0.5, scheduler: DispatchQueue.global())
            .flatMap { [weak self] (query) -> AnyPublisher<[Symbol], DataServiceError> in
                self!.container.services.data.searchStock(query)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion) in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("SearchView encountered error loading query: \(error)")
                    self?.list = []
                }
            } receiveValue: { [weak self] (value) in
                self?.list = value
            }
            .store(in: &bag)
    }
}

// MARK: - Preview

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(viewModel: .init(container: DIContainer.stub))
    }
}
