//
//  UIChartStyling.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 04.04.2021.
//

import Foundation
import SwiftUI
import SwiftUICharts

struct UIChartStyling {
    static let `default` = ChartStyle(
        backgroundColor: Color.white,
        accentColor: Color("Pale Black"),
        secondGradientColor: Color("Pale Black"),
        textColor: Color.black,
        legendTextColor: Color.gray,
        dropShadowColor: Color.gray
    )
}
