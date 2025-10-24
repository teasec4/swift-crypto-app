//
//  CoinRowSkeletonView.swift
//  CryptoAsyncAwait
//
//  Created by Max Kovalev on 10/22/25.
//

import SwiftUI

struct CoinRowSkeletonView: View {
    var body: some View {
        HStack(spacing: 8) {
            // Rank placeholder
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 20, height: 10)
                .shimmering()

            // Coin image placeholder
            Circle()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 20, height: 20)
                .shimmering()

            // Name + symbol placeholders
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.25))
                    .frame(width: 80, height: 12)
                    .shimmering()

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 10)
                    .shimmering()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Price + change placeholders
            VStack(alignment: .trailing, spacing: 4) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.25))
                    .frame(width: 60, height: 12)
                    .shimmering()

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 10)
                    .shimmering()
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack(spacing: 10) {
        ForEach(0..<5, id: \.self) { _ in
            CoinRowSkeletonView()
        }
    }
    .padding()
}
