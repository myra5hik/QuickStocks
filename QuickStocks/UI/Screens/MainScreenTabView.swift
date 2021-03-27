//
//  MainScreenTabView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 19.03.2021.
//

import SwiftUI

struct MainScreenTabView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var selection = 1
    
    var body: some View {
        TabView(selection: $selection) {
            SearchView(viewModel: .init(container: viewModel.container))
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(0)
            
            FinIndexView(viewModel: .init(container: viewModel.container, indexSymbol: "^NDX"))
                .tabItem {
                    Label("Nasdaq 100", systemImage: "list.dash")
                }
                .tag(1)
            
            FavouritesView(viewModel: .init(container: viewModel.container))
                .tabItem {
                    Label("Favourites", systemImage: "list.star")
                }
                .tag(2)
        }
        .accentColor(Color("Pale Black"))
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
