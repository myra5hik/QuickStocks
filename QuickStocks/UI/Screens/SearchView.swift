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
            VStack(alignment: .center, spacing: 0) {
                searchBar
                listView
                Spacer(minLength: 0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Search").h2()
                }
            }
        }
    }
}

private extension SearchView {
    var searchBar: some View {
        SearchBarView(
            input: $viewModel.searched,
            onDismiss: {
                viewModel.list = .idle
            }
        )
        .padding()
    }
    
    var listView: some View {
        switch viewModel.list {
        case .idle:
            return AnyView(suggestion)
        case .loading:
            return AnyView(loadingList)
        case .loaded(let list):
            return AnyView(loadedList(list))
        case .errorLoading:
            return AnyView(errorLoadingList)
        }
    }
    
    func loadedList(_ list: [Symbol]) -> some View {
        if list.isEmpty {
            return AnyView(emptyList)
        } else {
            return AnyView(
                StockListView(
                    viewModel: .init(
                        container: viewModel.container,
                        stockSymbols: list
                    )
                )
            )
        }
    }
    
    var loadingList: some View {
        return ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color("Pale Black")))
            .scaleEffect(2.0, anchor: .center)
            .padding()
    }
    
    var emptyList: some View {
        return Text("Couldn't find anything for \(viewModel.searched)").h3()
    }
    
    var errorLoadingList: some View {
        return Label("Network error", systemImage: "wifi.exclamationmark")
            .padding()
    }
    
    var suggestion: some View {
        return Text("Input search query").h3()
    }
}

// MARK: - ViewModel

extension SearchView {
    class ViewModel: ObservableObject {
        @Published var searched: String = ""
        @Published var list: Loadable<[Symbol]> = .idle
        
        let container: DIContainer
        private var disposables: Set<AnyCancellable>
        
        init(container: DIContainer) {
            self.container = container
            self.disposables = .init()
            subsribeToUserInput()
        }
    }
}

private extension SearchView.ViewModel {
    func subsribeToUserInput() -> Void {
        $searched
            .subscribe(on: DispatchQueue.global())
            .dropFirst()
            .handleEvents(receiveOutput: { [weak self] (userInput) in
                DispatchQueue.main.async {
                    self?.list = (userInput == "") ? .idle : .loading
                }
            })
            .debounce(for: 0.5, scheduler: DispatchQueue.global())
            .compactMap{ [weak self] (query) -> AnyPublisher<[Symbol], DataServiceError>? in
                self?.container.services.data.searchStock(query)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion) in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("SearchView encountered error loading query: \(error)")
                    self?.list = .errorLoading
                }
            } receiveValue: { [weak self] (value) in
                self?.list = (self?.searched == "") ? .idle : .loaded(value)
            }
            .store(in: &disposables)
    }
}

// MARK: - Preview

fileprivate extension SearchView {
    init(list: Loadable<[Symbol]>, query: String = "") {
        self.viewModel = .init(container: DIContainer.stub)
        self.viewModel.list = list
        self.viewModel.searched = query
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchView(list: .loaded(["AAPL"]))
            SearchView(list: .loaded([]), query: "Abcde")
            SearchView(list: .idle)
            SearchView(list: .loading)
            SearchView(list: .errorLoading)
        }
    }
}
