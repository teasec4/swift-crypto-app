//
//  UserAssetRowView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//
import SwiftUI

struct UserAssetRowView: View {
    let asset: UserAsset
    
    var body: some View {
        let totalValue = asset.coin.currentPrice * asset.amount
        
        HStack(spacing: 8) {
            // coin img
            AsyncImage(url: asset.coin.imageUrl) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } placeholder: {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 24, height: 24)
            }
            
           // coin lable
            VStack(alignment: .leading, spacing: 2) {
                Text(asset.coin.name)
                    .font(.system(size: 13, weight: .semibold))
                Text(asset.coin.symbol.uppercased())
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // amount and totalValue
            VStack(alignment: .trailing, spacing: 2) {
                Text(totalValue.toCurrency())
                    .font(.system(size: 13, weight: .semibold))
                    
                
                Text("\(asset.amount, specifier: "%.4f")")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        
        .contentShape(Rectangle())
    }
}
