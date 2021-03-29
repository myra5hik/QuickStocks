//
//  UITextFormatter.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 29.03.2021.
//

import Foundation

struct UITextFormatter {
    static func priceAsText(_ price: Double?) -> String {
        return (price != nil) ? "$" + String(format: "%.2f", price!) : "-"
    }
    
    static func changeAsText(abs: Double?, relative: Double?) -> String {
        guard !(abs == nil || relative == nil) else { return "-" }
        let sign = (abs! >= 0.0) ? "+" : "-"
        let unsignedAbs = (abs! >= 0.0) ? abs! : -abs!
        let unsignedRelative = (relative! >= 0.0) ? relative! : -relative!
        let rv = String(
            sign + "$" + String(format: "%.2f", unsignedAbs) + " " +
            "(" + String(format: "%.2f", unsignedRelative * 100) + "%)"
        )
        return rv
    }
}
