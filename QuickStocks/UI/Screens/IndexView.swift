//
//  IndexView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import SwiftUI
import Combine

struct IndexView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.viewModel.refresh()
    }
    
    var body: some View {
        NavigationView {
            StockListView(
                viewModel: .init(
                    container: viewModel.container,
                    stockSymbols: viewModel.index?.constituents ?? []
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.index?.symbol ?? "").h2()
                }
            }
        }
    }
}

// MARK: - ViewModel

extension IndexView {
    class ViewModel: ObservableObject {
        @Published private(set) var index: Index?
        
        let container: DIContainer
        private let indexSymbol: Symbol
        private var disposables = Set<AnyCancellable>()
        
        init(container: DIContainer, indexSymbol: Symbol) {
            self.container = container
            self.indexSymbol = indexSymbol
            self.index = nil
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
                        self.index = nil
                        print(error)
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] index in
                    guard let self = self else { return }
                    guard self.index != index else { return }
                    self.index = index
                }
                .store(in: &self.disposables)
        }
    }
}

// MARK: - Preview

fileprivate extension IndexView.ViewModel {
    convenience init() {
        self.init(container: DIContainer.stub, indexSymbol: "")
        self.index = StubData.indices[0]
    }
}

struct IndexView_Previews: PreviewProvider {
    static var previews: some View {
        IndexView(viewModel: IndexView.ViewModel.init())
    }
}