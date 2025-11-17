//
//  CoinRowView.swift
//  CryptoAsyncAwait
//


import SwiftUI

struct CoinRowView: View {
    let coin: Coin
    
    var body: some View {
        let marketCapText = coin.marketCapRank.map { "\($0)" } ?? "-"
        let change = coin.priceChangePercentage24H ?? 0
        let changeText = coin.priceChangePercentage24H.map { $0.toPercentString() } ?? "-"
        
        HStack(spacing: 8) {
            // Market cap rank
            Text(marketCapText)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 20, alignment: .leading)
            
            // Image
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
            
            // Name + symbol
            VStack(alignment: .leading, spacing: 2) {
                Text(coin.name)
                    .font(.system(size: 13, weight: .semibold))
                Text(coin.symbol.uppercased())
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Price + change
            VStack(alignment: .trailing, spacing: 2) {
                Text(coin.currentPrice.toCurrency())
                    .font(.system(size: 13, weight: .semibold))
                Text(changeText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(change > 0 ? .green : (change < 0 ? .red : .gray))
            }
            .frame(alignment: .trailing)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3) 
        .contentShape(Rectangle())
    }
}
