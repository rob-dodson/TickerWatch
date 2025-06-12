//
//  ContentView.swift
//  TickerWatch
//
//  Created by Robert Dodson on 5/18/25.
//

import SwiftUI
import SwiftData
import RobToolsLibrary


var pricetimer : Timer?
var selectedItem : Item?


struct ContentView: View
{
    @Environment(\.modelContext) private var modelContext
    
    @Query private var items: [Item]
    
    @State private var showSymbolSheet = false
    @State private var showAPIKeySheet = false
    @State private var showDataSheet = false
    
    @State private var newSymbol = ""
    @State private var newAPIKey = ""
    @State var navIsVisible : NavigationSplitViewVisibility = .automatic
    
    
    let doticker = true
    
    var exchange = Exchange()
    
    
    init()
    {
        RLog.log(msg: "TickerWatch starting...", name: "TickerWatch", rewindfile: true)
    }
    
    var body: some View
    {
        List(items.sorted(by: { $0.symbol < $1.symbol }))
        { item in
                setNavLink(item: item)
                .contextMenu
                {
                    Button("Delete", role: .destructive)
                    {
                        modelContext.delete( item)
                    }
                }
        }
        .toolbar
        {
            ToolbarItem
            {
                Button(action: addSymbolItem)
                {
                    Label("Add Symbol", systemImage: "plus")
                }
            }
            
            ToolbarItem
            {
                Button(action: addAPIKey)
                {
                    Label("Enter APIkey", systemImage: "key")
                }
            }
            
        }
        .sheet(isPresented: $showSymbolSheet)
        {
            callSymbolPanel()
        }
        .sheet(isPresented: $showAPIKeySheet)
        {
            callAPIKeyPanel()
        }
        .sheet(isPresented: $showDataSheet)
        {
            if let selecteditem = selectedItem
            {
                DataView(item: selecteditem)
            }
        }
        .onAppear()
        {
            setOnAppear( )
        }
    }
    
    
    func setNavLink(item: Item) -> some View
    {
        HStack
        {
            Text("\(item.symbol)")
                .font(.headline)
                .foregroundStyle(.green)
            
            DataView.truncPrice(value: item.price)
                .font(.headline)
                .foregroundStyle(.white)
            
            if item.change > 0
            {
                Image(systemName: "arrow.up")
                    .foregroundStyle(.green)
            }
            else
            {
                Image(systemName: "arrow.down")
                    .foregroundStyle(.red)
            }
        }
        .onTapGesture
        {
            selectedItem = item
            showDataSheet = true
        }
    }
    
    
    func setOnAppear()
    {
        checkForAPIKey()
     
        if doticker
        {
            initTickers()
        }
        
        if pricetimer == nil
        {
            pricetimer = Timer.scheduledTimer(withTimeInterval: 300,repeats: true)
            { timer in
                
                if doticker
                {
                    for item in items
                    {
                        exchange.getPrice(item: item,force: false)
                    }
                }
            }
        }
    }
    
    
    func checkForAPIKey()
    {
        do
        {
            guard let _ : String = try RKeychain.getFromKeychain(key: "twelvedata_apikey") else
            {
                showAPIKeySheet = true
                return
            }
        }
        catch
        {
            showAPIKeySheet = true
            RLog.log(msg:"Error reading API Key")
        }
    }
    
    
    func callSymbolPanel() -> some View
    {
        return SheetInputView(contextView:self, enteredText: $newSymbol)
    }
    
    
    func callAPIKeyPanel() -> some View
    {
        return APIKeyInputView(contextView:self, apikeyText: $newAPIKey)
    }
    
    
    private func initTickers()
    {
        for item in items
        {
            exchange.getPrice(item: item,force: true)
        }
    }
    
    
    func newAPIKey(newapikey:String)
    {
        do
        {
            try RKeychain.storeInKeychain(key: "twelvedata_apikey", value: newapikey)
        }
        catch
        {
            RLog.log(msg:"storeInKeychain error: \(error)")
        }
    }
    
    
    func newSymbol(newsymbol:String)
    {
         withAnimation
         {
             let newItem = Item(symbol:newsymbol)
             modelContext.insert(newItem)
             exchange.getPrice(item: newItem,force: true)
             exchange.getQuote(item: newItem, force: true)
         }
    }
    
    
    private func addSymbolItem()
    {
        showSymbolSheet = true
    }

    private func addAPIKey()
    {
        showAPIKeySheet = true
    }
    
    private func deleteItems(offsets: IndexSet)
    {
        withAnimation
        {
            for index in offsets
            {
                modelContext.delete(items.sorted { $0.symbol < $1.symbol }[index])
            }
        }
    }
}

