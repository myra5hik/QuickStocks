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
                logo
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
    var logo: some View {
        switch viewModel.stock {
        case .loaded(_): return AnyView(logoImage)
        default: return AnyView(Rectangle().foregroundColor(.gray).opacity(0.2))
        }
    }
    
    var logoImage: some View {
        if viewModel.logoImageViewModel == nil {
            viewModel.logoImageViewModel = .init(
                container: viewModel.container,
                symbol: viewModel.stockSymbol
            )
        }
        return LogoImageView(viewModel: viewModel.logoImageViewModel!)
    }
    
    var nameGroup: some View {
        return AnyView(
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 4) {
                    tickerText
                    starButton
                }
                companyNameText
            }
            .padding(.leading, 12.0)
        )
    }
    
    var tickerText: some View {
        switch viewModel.stock {
        case .loaded(let stock):
            return AnyView(Text(stock.symbol).h2().lineLimit(1))
        default:
            return AnyView(ObfuscatedTextView(w: CGFloat.random(in: 70...120), h: 16))
        }
    }
    
    var companyNameText: some View {
        switch viewModel.stock {
        case .loaded(let stock):
            return AnyView(Text(stock.name).subheader().lineLimit(1))
        default:
            return AnyView(
                ObfuscatedTextView(w: CGFloat.random(in: 50...70), h: 10).padding(.top, 1)
            )
        }
    }
    
    var starButton: some View {
        if case let .loaded(stock) = viewModel.stock {
            return AnyView(
                Image(systemName: "star.fill")
                    .font(Font.system(size: 16, weight: .black, design: .default))
                    .offset(x: 0.0, y: -1.0)
                    .foregroundColor(viewModel.isFav ? Color("Fav Yellow") : Color(.gray))
                    .onTapGesture {
                        viewModel.container.appState.toggleFav(symbol: stock.symbol)
                    }
            )
        }
        return AnyView(Text(""))
    }
    
    var priceGroup: some View {
        if case let .loaded(stock) = viewModel.stock {
            return AnyView(
                VStack(alignment: .center) {
                    Text(UITextFormatter.priceAsText(stock.current)).h2()
                    Text(UITextFormatter.changeAsText(
                            abs: stock.changeAbsolute,
                            relative: stock.changePercent)
                    )
                    .indicatingDynamics(rate: stock.changePercent)
                }
                .padding(.trailing, 12.0)
            )
        }
        return AnyView(Text(""))
    }
}

// MARK: - ViewModel

extension StockListRowView {
    class ViewModel: ObservableObject, Identifiable {
        @Published private(set) var stock: Loadable<Stock>
        @Published private(set) var isFav: Bool
        @Published var isOdd: Bool
        var logoImageViewModel: LogoImageView.ViewModel?
        
        let stockSymbol: Symbol
        var id: Symbol { stockSymbol }
        
        let container: DIContainer
        private let errorReporter: Optional<(FetcherError) -> ()>
        private var bag = Set<AnyCancellable>()
        
        init(
            container: DIContainer, stockSymbol: Symbol, isOdd: Bool,
            reportError: Optional<(FetcherError) -> ()> = nil
        ) {
            self.container = container
            self.stock = .idle
            self.stockSymbol = stockSymbol
            self.isOdd = isOdd
            self.isFav = false
            self.logoImageViewModel = nil
            self.errorReporter = reportError
            
            requestData(stockSymbol: stockSymbol)
            subscribeToFavs()
        }
    }
}

private extension StockListRowView.ViewModel {
    func requestData(stockSymbol: Symbol) -> Void {
        container.services.data.provideStock(stockSymbol)
            .subscribe(on: DispatchQueue.global())
            .retry(3)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] (completion) in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.errorReporter?(error)
                    self?.stock = .errorLoading
                }
            }, receiveValue: { [weak self] (value) in
                self?.stock = .loaded(value)
            })
            .store(in: &bag)
    }
    
    func subscribeToFavs() -> Void {
        container.appState.$favourites
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (set) in
                guard let symbol = self?.stockSymbol else { return }
                self?.isFav = set.contains(symbol)
            }
            .store(in: &bag)
    }
}

// MARK: - Previews

fileprivate extension StockListRowView.ViewModel {
    convenience init(stock: Loadable<Stock>, isOdd: Bool) {
        self.init(container: DIContainer.stub, stockSymbol: "", isOdd: isOdd)
        self.stock = stock
    }
}

struct StockListRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StockListRowView(model: .init(stock: .loading, isOdd: false))
            StockListRowView(model: .init(stock: .loaded(StubData.stocks[0]), isOdd: true))
            StockListRowView(model: .init(stock: .loaded(StubData.stocks[1]), isOdd: false))
        }
        .previewLayout(.fixed(width: 328, height: 68))
    }
}
