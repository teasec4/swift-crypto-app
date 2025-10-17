//
//  CoinListView.swift
//  CryptoAsyncAwait
//
//  Created by Max Kovalev on 10/2/25.
//

import SwiftUI

struct CoinListView: View {
    @ObservedObject var coinListViewModel : CoinListViewModel
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            List(coinListViewModel.coins, id: \.id) { coin in
                NavigationLink(destination: CoinDetailView(coin: coin)) {
                    CoinRowView(coin: coin)
                }
                
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .refreshable {
                await coinListViewModel.loadCoins()
            }
            .onAppear {
                Task {
                    if !coinListViewModel.hasLoadedInitially {
                        print("CoinListView appeared, loading coins for the first time...")
                        await coinListViewModel.loadCoins()
                    } else {
                        print("CoinListView appeared, skipping load (already loaded)")
                    }
                }
            }
            
            
        }
        
        .onReceive(coinListViewModel.$errorMessage) { error in
            if error != nil { showAlert = true }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(coinListViewModel.errorMessage ?? "Something went wrong"),
                dismissButton: .default(Text("OK")) {
                    coinListViewModel.errorMessage = nil
                }
            )
        }
    }
}
