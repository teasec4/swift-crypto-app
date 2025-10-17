//
//  InputField.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/15/25.
//
import SwiftUI

struct InputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    @FocusState private var isFocused: Bool
    @State private var showPassword = false

    var body: some View {
        Group {
            if isSecure {
                HStack {
                    if showPassword {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .focused($isFocused)
                    } else {
                        SecureField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .focused($isFocused)
                    }

                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .focused($isFocused)
            }
        }
        .inputFieldDecor(icon: icon, isFocused: $isFocused)
    }
}

