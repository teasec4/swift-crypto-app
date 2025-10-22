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
    private var marketCapText: String {
        coin.marketCapRank.map { "#\($0)" } ?? "-"
    }
    
    private var change: Double {
        coin.priceChangePercentage24H ?? 0
    }
    
    private var changeText: String {
        coin.priceChangePercentage24H.map { $0.toPercentString() } ?? "-"
    }
    
    var body: some View {
        
        VStack {
            
            VStack(alignment: .leading, spacing: 4){
                Text(coin.name)
                    .font(.headline)
                HStack( spacing: 2) {
                    Text(coin.currentPrice.toCurrency())
                        .font(.title)
                        .fontWeight(.bold)
                    Text(changeText)
                        .font(.caption)
                        .foregroundColor(change > 0 ? .green : (change < 0 ? .red : .gray))
                }
            }
            
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    AsyncImage(url: coin.imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    } placeholder: {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 20, height: 20)
                    }
                    
                    Text(coin.symbol.uppercased())
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let rank = coin.marketCapRank {
                        Text("#\(rank)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
        
    }
}
