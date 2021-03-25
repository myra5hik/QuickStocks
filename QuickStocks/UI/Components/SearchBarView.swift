//
//  SearchBarView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 23.03.2021.
//

import SwiftUI
import Combine

struct SearchBarView: View {
    @ObservedObject private(set) var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            roundedFrame
            HStack(alignment: .center, spacing: 10) {
                leftIcon
                textField
                if !viewModel.input.isEmpty {
                    rightIcon
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(minWidth: nil, idealWidth: 328.0, maxWidth: .infinity,
               minHeight: 48, idealHeight: 48, maxHeight: 48, alignment: .center)
    }
}

private extension SearchBarView {
    var roundedFrame: some View {
        Rectangle()
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 48 / 2))
            .overlay(
                RoundedRectangle(cornerRadius: 48 / 2)
                    .stroke(
                        Color("Pale Black"),
                        style: StrokeStyle(lineWidth: viewModel.isActive ? 2 : 1)
                    )
            )
    }
    
    var leftIcon: some View {
        Image(systemName: viewModel.isActive ? "arrow.backward" : "magnifyingglass")
            .font(.system(size: 20, weight: .regular))
            .foregroundColor(Color("Pale Black"))
            .onTapGesture {
                viewModel.input = ""
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
    }
    
    var rightIcon: some View {
        Image(systemName: "xmark")
            .font(.system(size: 20, weight: .regular))
            .foregroundColor(Color("Pale Black"))
            .onTapGesture {
                viewModel.input = ""
            }
    }
    
    var textField: some View {
        TextField("Find company or ticker", text: $viewModel.input) {
            viewModel.isActive = $0
        } onCommit: {
            viewModel.isActive = false
        }
            .font(.custom("Montserrat", size: 16))
            .foregroundColor(Color("Pale Black"))
            .disableAutocorrection(true)
    }
}

// MARK: - ViewModel

extension SearchBarView {
    class ViewModel: ObservableObject {
        @Published var isActive = false
        @Published var input = ""
        
        let container: DIContainer
        private var bag = Set<AnyCancellable>()
        
        init(container: DIContainer, publisher: Optional<(AnyPublisher<String, Never>) -> ()>) {
            self.container = container
            publisher?($input.eraseToAnyPublisher())
        }
    }
}

// MARK: - Preview

fileprivate extension SearchBarView.ViewModel {
    convenience init(active: Bool, input: String) {
        self.init(container: DIContainer.stub, publisher: nil)
        self.isActive = active
        self.input = input
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchBarView(viewModel: .init(active: false, input: ""))
            SearchBarView(viewModel: .init(active: true, input: ""))
            SearchBarView(viewModel: .init(active: true, input: "App"))
        }
        .previewLayout(.fixed(width: 350, height: 70))
    }
}
