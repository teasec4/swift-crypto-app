//
//  GlobalMarketHeaderView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/9/25.
//

import SwiftUI
import Combine

struct GlobalMarketHeaderView: View {
    @ObservedObject var viewModel: GlobalMarketViewModel

    var body: some View {
        ZStack{
            if viewModel.isLoading {
                ProgressView()
                    .tint(.gray)
            } else if let cap = viewModel.totalMarketCap,
                      let change = viewModel.change24h,
                        let dayVolume = viewModel.totalVolume
            {
                HStack {
                    Spacer()
                    VStack{
                        Text("Global Market Cap")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text("$\(formatNumber(cap))")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            Text(String(format: "%+.2f%%", change))
                                .font(.subheadline.bold())
                                .foregroundColor(change >= 0 ? .green : .red)
                                .transition(.opacity)
                        }
                    }
                    Spacer()
                    VStack{
                        Text("24h Volume")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        
                            Text("$\(formatNumber(dayVolume))")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            
                        
                    }
                    Spacer()
                }
                
                
            } else if let err = viewModel.errorMessage {
                Text("Ошибка: \(err)")
                    .font(.caption)
                    .foregroundColor(.red)
            } else {
                
                Text("Loading market data...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .task {
            await viewModel.loadGlobalData()
        }
    }

    private func formatNumber(_ num: Double) -> String {
        if num >= 1_000_000_000_000 {
            return String(format: "%.2fT", num / 1_000_000_000_000)
        } else if num >= 1_000_000_000 {
            return String(format: "%.2fB", num / 1_000_000_000)
        } else if num >= 1_000_000 {
            return String(format: "%.2fM", num / 1_000_000)
        } else {
            return String(format: "%.0f", num)
        }
    }
}
