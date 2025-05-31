//
//  Item.swift
//  TickerWatch
//
//  Created by Robert Dodson on 5/18/25.
//

import Foundation
import SwiftData

@Model
class Item
{
    var symbol: String = "symbol"
    var name: String?
    var exchange: String?
    var price: Float = 0.0
    var openprice: Float = 0.0
    var highprice: Float = 0.0
    var lowprice: Float = 0.0
    var closeprice: Float = 0.0
    var change: Float = 0.0
    var isMarketOpen = false
    var low52: Float = 0.0
    var high52: Float = 0.0
    var timestamp : TimeInterval = 0
    
    init(symbol: String)
    {
        self.symbol = symbol
    }
}
