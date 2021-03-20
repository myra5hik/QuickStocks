//
//  MainScreenTabView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import SwiftUI

struct MainScreenTabView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        TabView {
            StockListView(viewModel: .init(container: self.viewModel.container))
                .tabItem {
                    Label("Nasdaq 100", systemImage: "list.dash")
                }
            
            StockListView(viewModel: .init(container: self.viewModel.container))
                .tabItem {
                    Label("Home", systemImage: "list.star")
                }
        }
    }
}

// MARK: - ViewModel

extension MainScreenTabView {
    class ViewModel: ObservableObject {
        let container: DIContainer
        
        init(container: DIContainer) {
            self.container = container
        }
    }
}

 // MARK: - Preview

struct MainScreenTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenTabView(viewModel: .init(container: DIContainer.stub))
    }
}
