//
//  MainScreenTabView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import SwiftUI

struct MainScreenTabView: View {
    var body: some View {
        TabView {
            StockListView()
                .tabItem {
                    Label("Nasdaq 100", systemImage: "list.dash")
                }
            
            StockListView()
                .tabItem {
                    Label("Home", systemImage: "list.star")
                }
        }
    }
}

// MARK: - ViewModel

private extension MainScreenTabView {
    class ViewModel {
        let container: DIContainer
        
        init(container: DIContainer) {
            self.container = container
        }
    }
}

// MARK: - Preview

struct MainScreenTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenTabView()
    }
}
