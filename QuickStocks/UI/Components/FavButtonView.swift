//
//  FavButtonView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 05.04.2021.
//

import SwiftUI
import Combine

struct FavButtonView: View {
    @ObservedObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        starShape
            .onTapGesture {
                viewModel.container.appState.toggleFav(symbol: viewModel.associatedStock)
            }
    }
}

private extension FavButtonView {
    var starShape: some View {
        guard let isFav = viewModel.isFav else { return AnyView(EmptyView()) }
        
        switch viewModel.style {
        case .filled:
            return AnyView(
                Image(systemName: "star.fill")
                    .font(Font.system(size: 16, weight: .black, design: .default))
                    .foregroundColor(isFav ? Color("Fav Yellow") : Color(.gray))
            )
        case .stroked:
            return AnyView(
                Image(systemName: isFav ? "star.fill" : "star")
                    .font(Font.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(isFav ? Color("Fav Yellow") : Color("Pale Black"))
            )
        }
    }
}

// MARK: - ViewModel

extension FavButtonView {
    class ViewModel: ObservableObject {
        @Published var style: FavButtonStyle
        @Published var isFav: Bool?
        
        let associatedStock: Symbol
        let container: DIContainer
        private var disposables: Set<AnyCancellable> = []
        
        init(container: DIContainer, stockSymbol: Symbol, style: FavButtonStyle = .filled) {
            self.container = container
            self.associatedStock = stockSymbol
            self.style = style
            self.isFav = nil
            
            subscribeToFavs()
        }
    }
}

private extension FavButtonView.ViewModel {
    func subscribeToFavs() -> Void {
        container.appState.$favourites
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (set) in
                guard let self = self else { return }
                self.isFav = set.contains(self.associatedStock)
            }
            .store(in: &disposables)
    }
}

// MARK: - Styles

extension FavButtonView {
    enum FavButtonStyle {
        case filled
        case stroked
    }
}

// MARK: - Preview

fileprivate extension FavButtonView.ViewModel {
    convenience init(style: FavButtonView.FavButtonStyle, isFav: Bool) {
        self.init(container: DIContainer.stub, stockSymbol: "STUB", style: style)
        self.isFav = isFav
    }
}

struct FavButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FavButtonView(viewModel: .init(style: .filled, isFav: true))
            FavButtonView(viewModel: .init(style: .filled, isFav: false))
            FavButtonView(viewModel: .init(style: .stroked, isFav: true))
            FavButtonView(viewModel: .init(style: .stroked, isFav: false))
        }
        .previewLayout(.fixed(width: 30, height: 30))
    }
}
