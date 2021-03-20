//
//  StockListRowView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 20.03.2021.
//

import SwiftUI

struct StockListRowView: View {
    let stock: Stock
    
    var body: some View {
        Text(stock.name)
    }
}

struct StockListRowView_Previews: PreviewProvider {
    static var previews: some View {
        StockListRowView(stock: Stock(
                            symbol: "AAPL",
                            name: "Apple inc.",
                            currency: "USD",
                            logo: nil)
        )
    }
}
