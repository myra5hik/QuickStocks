//
//  UIStyling.swift
//  QuickStocks
//
//  Created by Alexander Tokarev on 22.03.2021.
//

import Foundation
import SwiftUI

extension Text {
    public func withAppFont(size: CGFloat) -> Text {
        return self.font(.custom("Montserrat", size: size))
    }
    
    public func h1() -> Text {
        return self.withAppFont(size: 28.0)
    }
    
    public func h2() -> Text {
        return self
            .withAppFont(size: 18.0).bold()
            .foregroundColor(Color("Pale Black"))
    }
    
    public func subheader() -> Text {
        return self.withAppFont(size: 11.0).fontWeight(.semibold)
    }
    
    public func indicatingGrowth() -> Text {
        return self
            .subheader()
            .foregroundColor(Color("Growing Green"))
    }
        
    public func indicatingDecline() -> Text {
        return self
            .subheader()
            .foregroundColor(Color("Declining Red"))
    }
    
    func indicatingDynamics(rate: Double?) -> Text {
        if rate == nil {
            return self.subheader()
        } else if rate! >= 0.0 {
            return self.indicatingGrowth()
        } else {
            return self.indicatingDecline()
        }
    }
}
