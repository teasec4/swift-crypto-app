//
//  CoinRowView.swift
//  CryptoAsyncAwait
//
//  Created by Stephan Dowless on 1/5/23.
//
import SwiftUI

struct CoinRowView: View {
    let coin: Coin
    
    var body: some View {
        // compute derived values safely
        let marketCapText = coin.marketCapRank.map { "\($0)" } ?? "-"
        let change = coin.priceChangePercentage24H ?? 0
        let changeText = coin.priceChangePercentage24H.map { $0.toPercentString() } ?? "-"
        
        return HStack {
            // Market cap rank
            Text(marketCapText)
                .font(.caption)
                .foregroundColor(.gray)
            
            // Image
            AsyncImage(url: coin.imageUrl) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.orange)
            } placeholder: {
                Circle()
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray5))
            }
            
            // Coin name info
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.leading, 4)
                
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .padding(.leading, 6)
            }
            .padding(.leading, 2)
            
            Spacer()
            
            // Coin price info
            VStack(alignment: .trailing, spacing: 4) {
                Text(coin.currentPrice.toCurrency())
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.leading, 4)
                
                Text(changeText)
                    .font(.caption)
                    .padding(.leading, 6)
                    .foregroundColor(change > 0 ? .green : (change < 0 ? .red : .primary))
            }
            .padding(.leading, 2)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
