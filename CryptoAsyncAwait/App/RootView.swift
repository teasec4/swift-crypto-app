//
//  RootView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/2/25.
//
import SwiftUI


struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
            Group {
                if authVM.user != nil {
                    ContentView()
                        .transition(.opacity.combined(with: .scale))
                } else {
                    LoginView()
                        .transition(.opacity)
                }
            }
        .animation(.easeInOut(duration: 0.25), value: authVM.user != nil)
    }
}


