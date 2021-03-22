//
//  StockListRowView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 20.03.2021.
//

import SwiftUI

struct StockListRowView: View {
    private let viewModel: ViewModel
    
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
                Image("AAPL")
                    .resizable()
                    .frame(width: 52.0, height: 52.0, alignment: .center)
                    .cornerRadius(10.0)
                    .padding(.leading, 8.0)
                
                VStack(alignment: .leading) {
                    Text(viewModel.stock.symbol).h2()
                    Text(viewModel.stock.name).subheader()
                }
                .padding(.leading, 12.0)
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text(priceAsText()).h2()
                    Text(changeAsText())
                        .indicatingDynamics(rate: viewModel.stock.changePercent)
                }
                .padding(.trailing, 12.0)
            }
            .frame(minWidth: nil, idealWidth: 328.0, maxWidth: .infinity,
                   minHeight: 68.0, idealHeight: 68.0, maxHeight: 68.0,
                   alignment: .leading)
        }
    }
}

private extension StockListRowView {
    func priceAsText() -> String {
        let value = viewModel.stock.current
        return (value != nil) ? "$" + String(format: "%.2f", value!) : "-"
    }
    
    func changeAsText() -> String {
        let abs = viewModel.stock.changeAbsolute
        let relative = viewModel.stock.changePercent
        guard !(abs == nil || relative == nil) else { return "-" }
        let sign = (abs! >= 0.0) ? "+" : "-"
        let unsignedAbs = (abs! >= 0.0) ? abs! : -abs!
        let unsignedRelative = (relative! >= 0.0) ? relative! : -relative!
        let rv = String(
            sign + "$" + String(format: "%.2f", unsignedAbs) + " " +
            "(" + String(format: "%.2f", unsignedRelative * 100) + "%)"
        )
        return rv
    }
}

// MARK: - ViewModel

extension StockListRowView {
    class ViewModel: ObservableObject {
        @Published var stock: Stock
        @Published var isOdd: Bool
        
        private let container: DIContainer
        
        init(container: DIContainer, stock: Stock, isOdd: Bool) {
            self.container = container
            self.stock = stock
            self.isOdd = isOdd
        }
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
