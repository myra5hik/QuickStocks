//
//  LogoImageView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 29.03.2021.
//

import SwiftUI
import Combine

struct LogoImageView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        switch viewModel.logo {
        case .loaded(let image):
            return AnyView(
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
        case .loading:
            return AnyView(ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color("Pale Black")))
                .padding())
        case .errorLoading:
            return AnyView(Image(systemName: "wifi.slash"))
        case .idle:
            viewModel.requestLogo()
            return AnyView(Rectangle().foregroundColor(Color("Pale Gray")))
        }
    }
}

// MARK: - ViewModel

extension LogoImageView {
    class ViewModel: ObservableObject {
        @Published var logo: Loadable<Image>
        
        private let symbol: Symbol
        private let container: DIContainer
        private var disposables: Set<AnyCancellable> = .init()
        
        init(container: DIContainer, symbol: Symbol) {
            self.symbol = symbol
            self.container = container
            self.logo = .idle
        }
    }
}

extension LogoImageView.ViewModel {
    func requestLogo() -> Void {
        container.services.data.provideLogo(symbol)
            .subscribe(on: DispatchQueue.global())
            .retry(3)
            .handleEvents(receiveSubscription: { [weak self] (_) in
                DispatchQueue.main.async {
                    self?.logo = .loading
                }
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion) in
                switch completion {
                case .failure(_):
                    self?.logo = .errorLoading
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (uiImage) in
                let image = Image(uiImage: uiImage)
                self?.logo = .loaded(image)
            }
            .store(in: &disposables)
    }
}

// MARK: - Preview

fileprivate extension LogoImageView {
    init(logo: Loadable<Image>) {
        self.viewModel = .init(container: DIContainer.stub, symbol: "")
        self.viewModel.logo = logo
    }
}

struct LogoImageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LogoImageView(logo: .loaded(Image("YNDX")))
            LogoImageView(logo: .loading)
            LogoImageView(logo: .errorLoading)
        }
        .previewLayout(.fixed(width: 60, height: 60))
    }
}
