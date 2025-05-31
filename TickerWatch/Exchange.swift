//
//  Exchange.swift
//  TickerWatch
//
//  Created by Robert Dodson on 5/18/25.
//

import Foundation
import RobToolsLibrary


class Exchange
{

    func callExchange(item:Item, url:String, operation: @escaping ([String:Any]) -> Void) -> Void
    {
        guard let url = URL(string: url) else
        {
            RLog.log(msg:"Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url)
        { data, response, error in
            
            do
            {
                if let error = error
                {
                    RLog.log(msg:"Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else
                {
                    RLog.log(msg:"No data received")
                    return
                }
                
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                {
                    operation(jsonObject)
                }
            }
            catch
            {
                RLog.log(msg:"Error \(error)")
            }
        }
       
        
        task.resume()
    }
    
    
    func getQuote(item:Item,force:Bool) -> Void
    {
        if isMarketOpenOnEastcoast() == false && force == false
        {
            return
        }
        
        do
        {
            guard let apikey : String = try RKeychain.getFromKeychain(key: "twelvedata_apikey") else
            {
                RLog.log(msg:"no api key")
                return
            }
            
            let urlString = "https://api.twelvedata.com/quote?symbol=\(item.symbol)&apikey=\(apikey)"
            
            callExchange(item: item, url: urlString)
            { jsonObject in
                
                //print(jsonObject)
                
                item.name = (jsonObject["name"] as AnyObject) as? String
                item.exchange = (jsonObject["exchange"] as AnyObject) as? String
                item.openprice = (jsonObject["open"] as AnyObject).floatValue ?? 0.0
                item.highprice = (jsonObject["high"] as AnyObject).floatValue ?? 0.0
                item.lowprice = (jsonObject["low"] as AnyObject).floatValue ?? 0.0
                item.closeprice = (jsonObject["close"] as AnyObject).floatValue ?? 0.0
                item.change = (jsonObject["change"] as AnyObject).floatValue ?? 0.0
                item.timestamp  = Date().timeIntervalSince1970
                item.isMarketOpen = (jsonObject["is_market_open"] as AnyObject).boolValue ?? false
                
                if let range = jsonObject["fifty_two_week"] as? Dictionary<String, Any>
                {
                    item.low52 = (range["low"] as AnyObject).floatValue ?? 0.0
                    item.high52 = (range["high"] as AnyObject).floatValue ?? 0.0
                }
            }
        }
        catch let error
        {
            RLog.log(msg:"Api key error: \(error)")
            return
        }
    }
    
    
    func getPrice(item:Item,force:Bool) -> Void
    {
        if isMarketOpenOnEastcoast() == false && force == false
        {
            return
        }
        
        do
        {
            guard let apikey : String = try RKeychain.getFromKeychain(key: "twelvedata_apikey") else
            {
                RLog.log(msg:"no api key")
                return
            }
            
            let urlString = "https://api.twelvedata.com/price?symbol=\(item.symbol)&apikey=\(apikey)"
            
            callExchange(item: item, url: urlString)
            { jsonObject in
                
                RLog.log(msg:"\(item.symbol): \(jsonObject)")
                
                item.price = (jsonObject["price"] as AnyObject).floatValue ?? 0.0
                item.lowprice = min(item.lowprice,item.price)
                item.highprice = max(item.highprice,item.price)
            }
        }
        catch
        {
            RLog.log(msg:"Error \(error)")
        }
    }
    
    
    func isMarketOpenOnEastcoast() -> Bool
    {
        let timeZone = TimeZone(identifier: "America/New_York")!
        let calendar = Calendar.current
        let components = calendar.dateComponents(in: timeZone, from: Date())
        
        if components.hour! >= 9 && components.hour! < 16 && components.weekday! > 1 && components.weekday! < 7
        {
           // RLog.log(msg:"OPEN")
            return true
        }
        else
        {
           // RLog.log(msg:"CLOSED")
            return false
        }
    }
    
}
