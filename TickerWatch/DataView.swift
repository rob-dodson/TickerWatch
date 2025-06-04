//
//  DataView.swift
//  TickerWatch
//
//  Created by Robert Dodson on 5/23/25.
//
import SwiftUI

struct DataView : View
{
    @Environment(\.dismiss) var dismiss
    
    var item:Item
    
    
    var body: some View
    {
        return VStack(alignment: .leading)
        {
            Text("\(item.symbol)")
                .font(.title)
                .foregroundStyle(.green)
            
            Text("\(item.name ?? item.symbol)")
                .font(.headline)
                .foregroundStyle(.gray)
            
            Text("\(item.exchange ?? "")")
                .font(.caption)
                .foregroundStyle(.gray)
            
            Text("\(formatDate(timeinsecs: item.timestamp))")
                .font(.caption)
                .foregroundStyle(.gray)
            
            priceBlock(label:"open:", value:item.openprice)
            priceBlock(label:"low:", value:item.lowprice)
            priceBlock(label:"high:", value:item.highprice)
            priceBlock(label:"close:",value: item.closeprice)
            priceBlock(label:"change:", value:item.change)
            priceBlock(label:"52 week low:", value:item.low52)
            priceBlock(label:"52 week high:", value:item.high52)
            
            Text("market: is \(item.isMarketOpen == true ? "open" : "closed")")
            
            Button("Close")
            {
                dismiss()
            }
        }
        .padding()
        .onChange(of: item,
        { oldValue, newValue in
            updateItem(item: item)
        })
        .font(.headline)
        .foregroundStyle(.white)
    }
    
    
    func updateItem(item:Item)
    {
        let exchange = Exchange()
        exchange.getQuote(item: item, force: true) //when does this get called?
    }
    
    
    func formatDate(timeinsecs:TimeInterval) -> String
    {
        let date = Date(timeIntervalSince1970: timeinsecs)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current  // Set to the current time zone
        formatter.dateStyle = .medium          // Choose your desired date style
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    
    func priceBlock(label:String,value:Float) -> some View
    {
        return HStack
        {
            Text("\(label)")
                .foregroundStyle(.gray)
            DataView.truncPrice(value: value)
                .foregroundStyle(.white)
        }
    }
    
    
    static func truncPrice(value:Float) -> some View
    {
        let price = String(format: "%.2f", value)
        return Text("\(price)")
    }
}
