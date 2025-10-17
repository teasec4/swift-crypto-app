//
//  InputFieldViewModifier.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/15/25.
//
import SwiftUI

struct InputFieldStyle: ViewModifier {
    let icon: String
    var isFocused: FocusState<Bool>.Binding

    func body(content: Content) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(isFocused.wrappedValue ? .green : .gray)
                .frame(width: 30)

            content
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 12)
        .frame(height: 50)
        .background(.ultraThinMaterial)
        .background(isFocused.wrappedValue ? Color.blue.opacity(0.15) : Color.clear)
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
    }
}

extension View {
    func inputFieldDecor(icon: String, isFocused: FocusState<Bool>.Binding) -> some View {
        modifier(InputFieldStyle(icon: icon, isFocused: isFocused))
    }
}
