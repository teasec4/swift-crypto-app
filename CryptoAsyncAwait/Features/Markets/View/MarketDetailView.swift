//
//  MarketDetailView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import SwiftUI

struct MarketDetailView: View {
    let coin: Coin
    @StateObject private var viewModel = MarketDetailViewModel()
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
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack(spacing: 12) {
                AsyncImage(url: coin.imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                } placeholder: {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(coin.name)
                        .font(.headline)
                    Text(coin.symbol.uppercased())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(coin.currentPrice.toCurrency())
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(changeText)
                        .font(.caption)
                        .foregroundColor(change > 0 ? .green : (change < 0 ? .red : .gray))
                }
            }
            
            // Stats
            VStack(alignment: .leading, spacing: 12) {
                StatRow(label: "Market Cap Rank", value: marketCapText)
                StatRow(label: "24h Change", value: changeText, valueColor: change > 0 ? .green : (change < 0 ? .red : .gray))
                StatRow(label: "Price", value: coin.currentPrice.toCurrency())
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper

struct StatRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}
