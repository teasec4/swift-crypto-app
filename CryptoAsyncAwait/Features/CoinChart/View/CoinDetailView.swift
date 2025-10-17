//
//  CoinDetailView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/2/25.
//

//
//  CoinDetailView.swift
//  CryptoAsyncAwait
//

import SwiftUI

struct CoinDetailView: View {
    let coin: Coin
    @StateObject private var viewModel = CoinDetailViewModel()
    
    var body: some View {
        
        VStack {
            CoinRowView(coin: coin)
            Spacer()
            if viewModel.isLoading {
                ProgressView("Loading chart...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                CoinChartView(data: viewModel.chartData)
            }
            Spacer()
        }
        .padding()
        .task {
            await viewModel.fetchChartData(for: coin.id)
        }
        .navigationTitle(coin.symbol.uppercased())
        .navigationBarTitleDisplayMode(.inline)
        
        
    }
}
