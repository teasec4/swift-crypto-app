//
//  CryptoAsyncAwaitApp.swift
//  CryptoAsyncAwait
//
//  Created by Stephan Dowless on 1/5/23.
//

import SwiftUI
import SwiftData

@main
struct CryptoAsyncAwaitApp: App {
    @StateObject private var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
               
        }
    }
}
