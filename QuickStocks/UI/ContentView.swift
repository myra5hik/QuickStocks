//
//  ContentView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 17.03.2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        MainScreenTabView(viewModel: .init(container: self.viewModel.container))
    }
}

// MARK: - ViewModel

extension ContentView {
    class ViewModel: ObservableObject {
        let container: DIContainer
        
        init(container: DIContainer) {
            self.container = container
        }
    }
}

// MARK: - Preview

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
