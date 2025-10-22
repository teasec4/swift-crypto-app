//
//  CoinErrorView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/22/25.
//

import SwiftUI

struct CoinErrorView: View {
    let message: String
    var retryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.red.opacity(0.25), .orange.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .red.opacity(0.3), radius: 20)
                    .overlay(
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 55, height: 55)
                            .foregroundStyle(.orange, .red)
                            .shadow(color: .orange.opacity(0.5), radius: 8, x: 0, y: 3)
                    )
            }

            Text("Something went wrong")
                .font(.title3.bold())
                .foregroundStyle(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let retry = retryAction {
                Button(action: retry) {
                    Label("Retry", systemImage: "arrow.clockwise.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
                                .cornerRadius(25)
                        )
                        .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 3)
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .ignoresSafeArea(edges: .bottom)
        .animation(.easeInOut(duration: 0.3), value: message)
    }
}

#Preview {
    CoinErrorView(message: "Failed to fetch latest coin data.") {
        print("Retry tapped")
    }
}
