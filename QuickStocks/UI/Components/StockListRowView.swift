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
        switch viewModel.stock {
        case .loaded(let stock):
            NavigationLink(
                destination: StockDetailsView(
                    viewModel: .init(container: viewModel.container, stock: stock)
                ),
                label: { fullRowRender }
            )
        default:
            fullRowRender
        }
    }
}

private extension StockListRowView {
    var fullRowRender: some View {
        AnyView(
            ZStack {
                if viewModel.isOdd {
                    Rectangle()
                        .foregroundColor(Color("Pale Gray"))
                        .cornerRadius(18.0)
                }
                
                HStack(alignment: .center, spacing: 0.0) {
                    leftLogoSquare
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
        )
    }
    
    var leftLogoSquare: some View {
        switch viewModel.stock {
        case .loaded(_):
            return AnyView(logoImage)
        case .errorLoading(let error):
            if case .apiCantProvide = error { fallthrough }
            return AnyView(
                ZStack {
                    Image(systemName: "wifi.slash").foregroundColor(Color("Pale Black"))
                    Rectangle().foregroundColor(.gray).opacity(0.2)
                }
            )
        default:
            return AnyView(Rectangle().foregroundColor(.gray).opacity(0.2))
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
                    upperTextLine
                    starButton
                }
                lowerTextLine
            }
            .padding(.leading, 12.0)
        )
    }
    
    var upperTextLine: some View {
        switch viewModel.stock {
        case .loaded(let stock):
            return AnyView(Text(stock.symbol).h2().lineLimit(1))
        case .errorLoading (let error):
            if case .apiCantProvide = error { fallthrough }
            return AnyView(Text(viewModel.stockSymbol).h2().lineLimit(1))
        default:
            return AnyView(ObfuscatedTextView(w: CGFloat.random(in: 70...120), h: 16))
        }
    }
    
    var lowerTextLine: some View {
        switch viewModel.stock {
        case .loaded(let stock):
            return AnyView(Text(stock.name).subheader().lineLimit(1))
        case .errorLoading(let error):
            if case .apiCantProvide = error { fallthrough }
            return AnyView(retryButton)
        default:
            return AnyView(
                ObfuscatedTextView(w: CGFloat.random(in: 50...70), h: 10).padding(.top, 1)
            )
        }
    }
    
    var starButton: some View {
        if case let .loaded(stock) = viewModel.stock {
            return AnyView(
                FavButtonView(
                    viewModel: .init(
                        container: viewModel.container,
                        stockSymbol: stock.symbol,
                        style: .filled
                    )
                )
                .offset(x: 0.0, y: -1.0)
            )
        }
        return AnyView(EmptyView())
    }
    
    var retryButton: some View {
        Button(action: {
            viewModel.requestData()
        }, label: {
            HStack(alignment: .center, spacing: 4) {
                Text("Retry").subheader()
                Image(systemName: "arrow.counterclockwise").font(.system(size: 10))
            }.foregroundColor(.blue)
        })
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
        @Published private(set) var stock: Loadable<Stock, FetcherError>
        @Published var isOdd: Bool
        var logoImageViewModel: LogoImageView.ViewModel?
        
        let stockSymbol: Symbol
        var id: Symbol { stockSymbol }
        
        let container: DIContainer
        private let errorReporter: Optional<(FetcherError) -> ()>
        private var disposables = Set<AnyCancellable>()
        
        init(
            container: DIContainer, stockSymbol: Symbol, isOdd: Bool,
            reportError: Optional<(FetcherError) -> ()> = nil
        ) {
            self.container = container
            self.stock = .idle
            self.stockSymbol = stockSymbol
            self.isOdd = isOdd
            self.logoImageViewModel = nil
            self.errorReporter = reportError
            
            requestData()
        }
    }
}

private extension StockListRowView.ViewModel {
    func requestData() -> Void {
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
                    self?.stock = .errorLoading(error)
                }
            }, receiveValue: { [weak self] (value) in
                self?.stock = .loaded(value)
            })
            .store(in: &disposables)
    }
}

// MARK: - Previews

fileprivate extension StockListRowView.ViewModel {
    convenience init(stock: Loadable<Stock, FetcherError>, isOdd: Bool) {
        self.init(container: DIContainer.stub, stockSymbol: "STUB", isOdd: isOdd)
        self.stock = stock
    }
}

struct StockListRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StockListRowView(model: .init(stock: .loading, isOdd: false))
            StockListRowView(model: .init(stock: .errorLoading(.parsing), isOdd: false))
            StockListRowView(model: .init(stock: .loaded(StubData.stocks[0]), isOdd: true))
            StockListRowView(model: .init(stock: .loaded(StubData.stocks[1]), isOdd: false))
        }
        .previewLayout(.fixed(width: 328, height: 68))
    }
}
