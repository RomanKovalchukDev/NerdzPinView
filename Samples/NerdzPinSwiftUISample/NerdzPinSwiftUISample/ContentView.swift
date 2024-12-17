//
//  ContentView.swift
//  NerdzPinSwiftUISample
//
//  Created by Roman Kovalchuk on 16.12.2024.
//

import SwiftUI
import NerdzPinView

struct ContentView: View {
    
    @State var text: String = ""
    @FocusState var isFirstFocussed: Bool
    
    @State var text2: String = ""
    @FocusState var isSecondFocussed: Bool
    
    var body: some View {
        VStack {
            Text("Text for the first field \(text)")
            
            NerdzBorderedPinView(
                text: $text,
                viewState: .constant(.normal),
                isFocused: $isFirstFocussed,
                keyboardType: .alphabet
            )
                .frame(height: 50)
                .padding()
            
            Text("Text for the second field \(text2)")
            
            NerdzUnderlinePinView(text: $text2)
                .frame(height: 50)
                .padding()
            
            Button(
                action: {
                    debugPrint(text)
                    text = "Xd"
                    debugPrint(text)
                    debugPrint("Should set text to xd")
                },
                label: {
                    Text("Set first text to Xd")
                        .font(.headline)
                        .foregroundStyle(Color.blue)
                }
            )
        }
            .onTapGesture {
                isFirstFocussed = false
                isSecondFocussed = false
            }
    }
}

#Preview {
    ContentView()
}
