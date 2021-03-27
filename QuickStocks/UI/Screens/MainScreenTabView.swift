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
        TabView(selection: .constant(0)) {
            SearchView(viewModel: .init(container: viewModel.container))
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            FinIndexView(viewModel: .init(container: viewModel.container, indexSymbol: "^NDX"))
                .tabItem {
                    Label("Nasdaq 100", systemImage: "list.dash")
                }
            
            FavouritesView(viewModel: .init(container: viewModel.container))
                .tabItem {
                    Label("Favourites", systemImage: "list.star")
                }
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
