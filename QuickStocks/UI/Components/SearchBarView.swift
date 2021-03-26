//
//  SearchBarView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 23.03.2021.
//

import SwiftUI
import Combine

struct SearchBarView: View {
    @Binding var input: String
    @State private var isActive = false
    
    private let onDismiss: Optional<() -> ()>
    
    init(input: Binding<String>, onDismiss: Optional<() -> ()> = nil) {
        self._input = input
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            roundedFrame
            HStack(alignment: .center, spacing: 10) {
                leftIcon
                textField
                if !input.isEmpty {
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
                        style: StrokeStyle(lineWidth: isActive ? 2 : 1)
                    )
            )
    }
    
    var leftIcon: some View {
        Image(systemName: isActive ? "arrow.backward" : "magnifyingglass")
            .font(.system(size: 20, weight: .regular))
            .foregroundColor(Color("Pale Black"))
            .onTapGesture {
                if isActive {
                    input = ""
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                    onDismiss?()
                }
            }
    }
    
    var rightIcon: some View {
        Image(systemName: "xmark")
            .font(.system(size: 20, weight: .regular))
            .foregroundColor(Color("Pale Black"))
            .onTapGesture {
                input = ""
                onDismiss?()
            }
    }
    
    var textField: some View {
        TextField("Find company or ticker", text: $input) {
            isActive = $0
        } onCommit: {
            isActive = false
        }
        .font(.custom("Montserrat", size: 16))
        .foregroundColor(Color("Pale Black"))
        .disableAutocorrection(true)
        .autocapitalization(.none)
    }
}

// MARK: - Preview

fileprivate extension SearchBarView {
    init(active: Bool, input: String) {
        self.init(input: .constant(input))
        self.isActive = active
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchBarView(active: false, input: "")
            SearchBarView(active: true, input: "")
            SearchBarView(active: true, input: "App")
        }
        .previewLayout(.fixed(width: 350, height: 70))
    }
}
