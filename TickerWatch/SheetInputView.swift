//
//  SheetInputView.swift
//  TickerWatch
//
//  Created by Robert Dodson on 5/23/25.
//
import SwiftUI

struct SheetInputView: View
{
    @Environment(\.dismiss) var dismiss
    
    var contextView: ContentView
    
    @Binding var enteredText: String
    
    var body: some View
    {
        VStack
        {
            Text("New Symbol:")
                .font(.headline)
                .padding()
            
            TextField("symbol", text: $enteredText)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Submit")
            {
                contextView.newSymbol(newsymbol: enteredText)
                dismiss()
            }
            
            .padding()
        }
        .onSubmit
        {
            contextView.newSymbol(newsymbol: enteredText)
            dismiss()
        }
    }
}
