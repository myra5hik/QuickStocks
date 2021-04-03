//
//  ObfuscatedTextView.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 03.04.2021.
//

import SwiftUI

struct ObfuscatedTextView: View {
    private var height: CGFloat
    private var width: CGFloat
    private var cornerRadius: CGFloat { min(height * 0.35, 6) }
    
    init(w: CGFloat, h: CGFloat) {
        self.height = h
        self.width = w
    }
    
    var body: some View {
        Rectangle()
            .foregroundColor(.gray)
            .opacity(0.2)
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
    }
}

struct ObfuscatedTextView_Previews: PreviewProvider {
    static var previews: some View {
        ObfuscatedTextView(w: 50, h: 10)
            .previewLayout(.fixed(width: 100, height: 30))
    }
}
