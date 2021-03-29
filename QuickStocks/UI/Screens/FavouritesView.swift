//
//  FavouritesView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 23.03.2021.
//

import SwiftUI
import Combine

struct FavouritesView: View {
    @ObservedObject private(set) var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Favourites").h2()
                }
            }
        }
    }
}

private extension FavouritesView {
    var content: some View {
        if viewModel.list.isEmpty {
            return AnyView(emptyList)
        } else {
            return AnyView(filledList)
        }
    }
    
    var emptyList: some View {
        VStack {
            Image(systemName: "star.slash.fill")
                .font(.system(size: 115))
                .foregroundColor(Color("Pale Gray"))
                .padding()
            Text("Your Favourites\nare empty")
                .withAppFont(size: 20)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
    }
    
    var filledList: some View {
        StockListView(
            viewModel: .init(container: viewModel.container, stockSymbols: viewModel.list)
        )
    }
}

// MARK: - ViewModel

extension FavouritesView {
    class ViewModel: ObservableObject {
        @Published var list: [Symbol]
        
        let container: DIContainer
        private var bag: Set<AnyCancellable>
        
        init(container: DIContainer) {
            self.container = container
            self.list = []
            self.bag = .init()
            
            subscribeToFavs()
        }
    }
}

private extension FavouritesView.ViewModel {
    func subscribeToFavs() -> Void {
        container.appState.$favourites
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (set) in
                self?.list = Array(set)
            }
            .store(in: &bag)
    }
}

struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritesView(viewModel: .init(container: DIContainer.stub))
    }
}
