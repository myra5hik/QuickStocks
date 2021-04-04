//
//  PriceChartView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 04.04.2021.
//

import SwiftUI
import Combine
import SwiftUICharts

struct PriceChartView: View {
    @ObservedObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        switch viewModel.data {
        case .idle:
            viewModel.requestData()
            return AnyView(loadingChart)
        case .loading:
            return AnyView(loadingChart)
        case .loaded(let data):
            return AnyView(loadedChart(data: data))
        case .errorLoading(_):
            return AnyView(Label("Network Error", systemImage: "wifi.slash"))
        }
    }
}

private extension PriceChartView {
    func loadedChart(data: [Double]) -> some View {
        return LineView(
            data: data,
            title: nil,
            legend: nil,
            style: UIChartStyling.default,
            valueSpecifier: "$%.0f",
            legendSpecifier: "$%.0f"
        )
        .font(.custom("Montserrat", size: 12))
    }
    
    var loadingChart: some View {
        return AnyView(
            ZStack {
                Rectangle()
                    .cornerRadius(15)
                    .foregroundColor(Color("Pale Gray"))
                    .scaleEffect(x: 1.0, y: 0.9, anchor: .bottom)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color("Pale Black")))
                    .padding()
            }
        )
    }
}

// MARK: - ViewModel

extension PriceChartView {
    class ViewModel: ObservableObject {
        @Published var data: Loadable<[Double], FetcherError>
        let stockSymbol: Symbol
        
        private let container: DIContainer
        private var disposables: Set<AnyCancellable> = []
        
        init(container: DIContainer, stockSymbol: Symbol) {
            self.container = container
            self.stockSymbol = stockSymbol
            self.data = .idle
        }
    }
}

private extension PriceChartView.ViewModel {
    func requestData() -> Void {
        container.services.data.provideHistoricPrices(stockSymbol)
            .subscribe(on: DispatchQueue.global())
            .handleEvents(receiveSubscription: { [weak self] (_) in
                DispatchQueue.main.async {
                    self?.data = .loading
                }
            })
            .retry(3)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion) in
                switch completion {
                case .failure(let error):
                    self?.data = .errorLoading(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (value) in
                self?.data = .loaded(value)
            }
            .store(in: &disposables)
    }
}

// MARK: - Preview

struct PriceChartView_Previews: PreviewProvider {
    static var previews: some View {
        PriceChartView(
            viewModel: .init(
                container: DIContainer.stub, stockSymbol: "AAPL"
            )
        )
        .padding()
        .previewLayout(.fixed(width: 500, height: 500))
    }
}
