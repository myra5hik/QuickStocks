//
//  StockDetailsView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 04.04.2021.
//

import SwiftUI
import Combine

struct StockDetailsView: View {
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                priceGroup
                chart
                details
                Spacer(minLength: 0)
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(viewModel.stock.symbol).h2()
                    Text(viewModel.stock.name).withAppFont(size: 12)
                }
            }
        }
    }
}

private extension StockDetailsView {
    var priceGroup: some View {
        VStack {
            Text(UITextFormatter.priceAsText(viewModel.stock.current))
                .withAppFont(size: 28).bold()
            Text(UITextFormatter.changeAsText(
                    abs: viewModel.stock.changeAbsolute,
                    relative: viewModel.stock.changePercent)
            )
            .indicatingDynamics(rate: viewModel.stock.changePercent)
        }
    }
    
    var chart: some View {
        PriceChartView(
            viewModel: .init(
                container: viewModel.container, stockSymbol: viewModel.stock.symbol
            )
        )
        .padding([.horizontal, .bottom], 16)
        .frame(
            minWidth: 0, idealWidth: 0, maxWidth: .infinity,
            minHeight: 150, idealHeight: 300, maxHeight: .infinity,
            alignment: .center
        )
    }
    
    var details: some View {
        VStack(alignment: .center, spacing: 12, content: {
            row(
                label: "52W High",
                value: UITextFormatter.priceAsText(viewModel.stock.week52High)
            )
            row(
                label: "52W Low",
                value: UITextFormatter.priceAsText(viewModel.stock.week52Low)
            )
            row(
                label: "P/E",
                value: UITextFormatter.peAsText(pe: viewModel.stock.peRatio)
            )
        })
        .padding(.vertical, 16)
    }
    
    func row(label: String, value: String) -> some View {
        return AnyView(
            HStack {
                Text(label).h2()
                Spacer(minLength: 50)
                Text(value).withAppFont(size: 16)
            }
            .padding(.horizontal, 32)
        )
    }
}

// MARK: - ViewModel

extension StockDetailsView {
    class ViewModel: ObservableObject {
        @Published private(set) var stock: Stock
        
        let container: DIContainer
        
        init(container: DIContainer, stock: Stock) {
            self.container = container
            self.stock = stock
        }
    }
}

// MARK: - Preview

struct StockDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        StockDetailsView(
            viewModel: .init(
                container: DIContainer.stub,
                stock: StubData.stocks[0]
            )
        )
    }
}
