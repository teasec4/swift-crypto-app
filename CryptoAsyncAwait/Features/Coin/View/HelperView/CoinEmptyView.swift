//
//  CoinEmptyView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/22/25.
//

import SwiftUI

struct CoinEmptyView: View {
    var retryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.gray.opacity(0.15), .gray.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "bitcoinsign.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(
                                LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: .yellow.opacity(0.4), radius: 15, x: 0, y: 8)
                    )
                    .rotationEffect(.degrees(10))
                    .opacity(0.9)
            }
            .padding(.bottom, 8)

            Text("No Coins Found")
                .font(.title3.bold())
                .foregroundStyle(.primary)

            Text("Try refreshing the list or check your connection.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let retry = retryAction {
                Button(action: retry) {
                    Label("Retry", systemImage: "arrow.clockwise.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
                                .cornerRadius(25)
                        )
                        .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 4)
                }
                .padding(.top, 16)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .ignoresSafeArea(edges: .bottom)
        .animation(.easeInOut(duration: 0.3), value: retryAction != nil)
    }
}

#Preview {
    CoinEmptyView {
        print("Retry tapped")
    }
}
