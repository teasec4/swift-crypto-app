//
//  CoinListView.swift
//  CryptoAsyncAwait
//
//  Created by Max Kovalev on 10/2/25.
//

import SwiftUI

struct CoinListView: View {
    @ObservedObject var coinListViewModel : CoinListViewModel
    
    var body: some View {
        bodyContent
            .task {
                if !coinListViewModel.hasLoadedInitially {
                    await coinListViewModel.loadCoins()
                }
            }
    }
    
    @ViewBuilder
    private var bodyContent: some View{
        switch coinListViewModel.screenState {
        case .loading:
            ProgressView()
        case .error(let error):
            VStack(spacing: 16) {
                Text("❌ \(error)")
                    .foregroundColor(.red)
                Button("Retry") {
                    Task { await coinListViewModel.loadCoins() }
                }
            }
            .padding()
        case .empty:
            VStack{
                Text("No data")
            }
        case .content(let coins):
            List(coins, id: \.id) { coin in
                NavigationLink(destination: CoinDetailView(coin: coin)) {
                    CoinRowView(coin: coin)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .refreshable {
                await coinListViewModel.loadCoins()
            }
            
        }
    }
}
