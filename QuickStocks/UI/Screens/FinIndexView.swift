//
//  FinIndexView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import SwiftUI
import Combine

struct FinIndexView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.viewModel.refresh()
    }
    
    var body: some View {
        NavigationView {
            list
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { () -> Text in 
                    var text = ""
                    switch viewModel.index {
                    case .loaded(let value):
                        text = value.name
                    case .loading:
                        text = "Loading..."
                    default:
                        text = ""
                    }
                    return Text(text).h2()
                }
            }
        }
    }
}

private extension FinIndexView {
    var list: some View {
        switch viewModel.index {
        case .idle:
            viewModel.refresh()
            return AnyView(loadingList)
        case .loading:
            return AnyView(loadingList)
        case .errorLoading:
            return AnyView(errorLoadingList)
        case .loaded(let value):
            return AnyView(loadedList(value.constituents))
        }
    }
    
    var loadingList: some View {
        return ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color("Pale Black")))
            .scaleEffect(2.0, anchor: .center)
            .padding()
    }
    
    func loadedList(_ list: [Symbol]) -> some View {
        StockListView(
            viewModel: .init(
                container: viewModel.container,
                stockSymbols: Just(list).eraseToAnyPublisher()
            )
        )
    }
    
    var errorLoadingList: some View {
        return Label("Network error", systemImage: "wifi.exclamationmark")
            .padding()
    }
}

// MARK: - ViewModel

extension FinIndexView {
    class ViewModel: ObservableObject {
        @Published private(set) var index: Loadable<FinIndex>
        
        let container: DIContainer
        private let indexSymbol: Symbol
        private var disposables = Set<AnyCancellable>()
        
        init(container: DIContainer, indexSymbol: Symbol) {
            self.container = container
            self.indexSymbol = indexSymbol
            self.index = .idle
        }
        
        func refresh() -> Void {
            self.container.services.data
                .provideIndex(self.indexSymbol)
                .subscribe(on: DispatchQueue.global())
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let self = self else { return }
                    switch value {
                    case .failure(let error):
                        self.index = .errorLoading
                        print(error)
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] index in
                    guard let self = self else { return }
                    self.index = .loaded(index)
                }
                .store(in: &self.disposables)
        }
    }
}

// MARK: - Preview

fileprivate extension FinIndexView.ViewModel {
    convenience init() {
        self.init(container: DIContainer.stub, indexSymbol: "")
        self.index = .loaded(StubData.indices[0])
    }
}

struct IndexView_Previews: PreviewProvider {
    static var previews: some View {
        FinIndexView(viewModel: FinIndexView.ViewModel.init())
    }
}
