//
//  StockListRowView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 20.03.2021.
//

import SwiftUI
import Combine

struct StockListRowView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(model: ViewModel) {
        self.viewModel = model
    }
    
    var body: some View {
        ZStack {
            if viewModel.isOdd {
                Rectangle()
                    .foregroundColor(Color("Pale Gray"))
                    .cornerRadius(18.0)
            }
            
            HStack(alignment: .center, spacing: 0.0) {
                logoImage
                    .frame(width: 52.0, height: 52.0, alignment: .center)
                    .cornerRadius(10.0)
                    .padding(.leading, 8.0)
                nameGroup
                Spacer()
                priceGroup
            }
            .frame(minWidth: nil, idealWidth: 328.0, maxWidth: .infinity,
                   minHeight: 68.0, idealHeight: 68.0, maxHeight: 68.0,
                   alignment: .leading)
        }
    }
}

private extension StockListRowView {
    var logoImage: some View {
        switch viewModel.logo {
        case .loaded(let image):
            return AnyView(
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
        case .loading:
            return AnyView(ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color("Pale Black")))
                .padding())
        case .errorLoading:
            return AnyView(Image(systemName: "wifi.slash"))
        case .idle:
            viewModel.requestLogo()
            return AnyView(Rectangle().foregroundColor(Color("Pale Gray")))
        }
    }
    
    var nameGroup: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 4) {
                Text(viewModel.stock.symbol).h2().lineLimit(1)
                starButton
            }
            Text(viewModel.stock.name).subheader().lineLimit(1)
        }
        .padding(.leading, 12.0)
    }
    
    var starButton: some View {
        Image(systemName: "star.fill")
            .font(Font.system(size: 16, weight: .black, design: .default))
            .offset(x: 0.0, y: -1.0)
            .foregroundColor(viewModel.isFav ? Color("Fav Yellow") : Color(.gray))
            .onTapGesture {
                viewModel.container.appState.toggle(symbol: viewModel.stock.symbol)
            }
    }
    
    var priceGroup: some View {
        VStack(alignment: .center) {
            Text(UITextFormatter.priceAsText(viewModel.stock.current)).h2()
            Text(UITextFormatter.changeAsText(
                    abs: viewModel.stock.changeAbsolute,
                    relative: viewModel.stock.changePercent)
            )
            .indicatingDynamics(rate: viewModel.stock.changePercent)
        }
        .padding(.trailing, 12.0)
    }
}

// MARK: - ViewModel

extension StockListRowView {
    class ViewModel: ObservableObject {
        @Published var stock: Stock
        @Published var isOdd: Bool
        @Published var isFav: Bool
        @Published var logo: Loadable<Image>
        
        let container: DIContainer
        
        private var bag = Set<AnyCancellable>()
        
        init(container: DIContainer, stock: Stock, isOdd: Bool) {
            self.container = container
            self.stock = stock
            self.isOdd = isOdd
            self.isFav = false
            self.logo = .idle
            
            subscribeToFavs()
        }
    }
}

private extension StockListRowView.ViewModel {
    func subscribeToFavs() -> Void {
        container.appState.$favourites
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (set) in
                guard let symbol = self?.stock.symbol else { return }
                self?.isFav = set.contains(symbol)
            }
            .store(in: &bag)
    }
    
    func requestLogo() -> Void {
        container.services.data.provideLogo(stock.symbol)
            .subscribe(on: DispatchQueue.global())
            .retry(3)
            .handleEvents(receiveSubscription: { [weak self] (_) in
                DispatchQueue.main.async {
                    self?.logo = .loading
                }
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion) in
                switch completion {
                case .failure(_):
                    self?.logo = .errorLoading
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (uiImage) in
                let image = Image(uiImage: uiImage)
                self?.logo = .loaded(image)
            }
            .store(in: &bag)
    }
}

// MARK: - Previews

struct StockListRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StockListRowView(model: .init(container: DIContainer.stub,
                                          stock: StubData.stocks[0], isOdd: true))
            StockListRowView(model: .init(container: DIContainer.stub,
                                          stock: StubData.stocks[1], isOdd: false))
        }
        .previewLayout(.fixed(width: 328, height: 68))
    }
}
