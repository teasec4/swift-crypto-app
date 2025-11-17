//
//  PortfolioAssetRowView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import SwiftUI

struct PortfolioAssetRowView: View {
    let asset: UserAsset
    let totalPortfolioValue: Double
    
    var body: some View {
        let totalValue = asset.coin.currentPrice * asset.amount
        let portfolioPercentage = totalPortfolioValue > 0 
            ? (totalValue / totalPortfolioValue) * 100 
            : 0
        
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Coin image
                AsyncImage(url: asset.coin.imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Circle()
                        .fill(Color(.systemGray5))
                }
                .frame(width: 40, height: 40)
                .cornerRadius(20)
                
                // Left: Coin info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(asset.coin.name)
                            .font(.system(size: 15, weight: .semibold))
                        
                        // Portfolio percentage badge
                        Text("\(portfolioPercentage, specifier: "%.1f")%")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(4)
                    }
                    
                    HStack(spacing: 6) {
                        Text(asset.coin.symbol.uppercased())
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(asset.amount, specifier: "%.4f")")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    // Price per coin
                    Text("\(asset.coin.currentPrice.toCurrency())/coin")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .opacity(0.7)
                }
                
                Spacer()
                
                // Right: Value info
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(totalValue.toCurrency())
                            .font(.system(size: 15, weight: .semibold))
                        
                        // Price change indicator (if available)
                        priceChangeIndicator(asset.coin.priceChangePercentage24H)
                    }
                    
                    // Progress bar showing portfolio allocation
                    ProgressView(value: portfolioPercentage / 100)
                        .frame(maxWidth: 80)
                        .tint(Color.blue.opacity(0.7))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            
            Divider()
                .padding(.leading, 52)
                .opacity(0.3)
        }
        .contentShape(Rectangle())
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private func priceChangeIndicator(_ change: Double?) -> some View {
        if let change = change {
            let isPositive = change >= 0
            HStack(spacing: 2) {
                Image(systemName: isPositive ? "triangle.fill" : "triangle.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(isPositive ? .green : .red)
                    .rotationEffect(.degrees(isPositive ? 0 : 180))
                
                Text("\(abs(change), specifier: "%.1f")%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isPositive ? .green : .red)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background((isPositive ? Color.green : Color.red).opacity(0.15))
            .cornerRadius(4)
        }
    }
}
