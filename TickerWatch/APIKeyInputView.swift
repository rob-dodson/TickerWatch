//
//  APIKeyInputView.swift
//  TickerWatch
//
//  Created by Robert Dodson on 5/30/25.
//

import SwiftUI

struct APIKeyInputView: View
{
    @Environment(\.dismiss) var dismiss
    
    var contextView: ContentView
    
    @Binding var apikeyText: String
    
    var body: some View
    {
        VStack
        {
            Text("Enter twelvedata.com API Key:")
                .font(.headline)
                .padding()
            
            TextField("APIKey", text: $apikeyText)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            HStack
            {
                Button("Cancel")
                {
                    dismiss()
                }
                
                Button("Submit")
                {
                    contextView.newAPIKey(newapikey: apikeyText)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                
            }
            .padding()
        }
        .onSubmit
        {
            contextView.newAPIKey(newapikey: apikeyText)
            dismiss()
        }
    }
}

