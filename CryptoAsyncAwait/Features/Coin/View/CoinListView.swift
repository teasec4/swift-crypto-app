//
//  CoinListView.swift
//  CryptoAsyncAwait
//
//  Created by Max Kovalev on 10/2/25.
//

import SwiftUI

struct CoinListView: View {
    @ObservedObject var coinListViewModel : CoinListViewModel
    
    var body: some View {
        bodyContent
            .task {
                await coinListViewModel.loadCoins()
            }
    }
    
    @ViewBuilder
    private var bodyContent: some View{
        switch coinListViewModel.state {
        case .loading:
            VStack(spacing: 8) {
                    ForEach(0..<14, id: \.self) { _ in
                        CoinRowSkeletonView()
                    }
                }
        case .error(let error):
            CoinErrorView(message: error, retryAction: coinListViewModel.reloadTask)
        case .empty:
            CoinEmptyView(retryAction: coinListViewModel.reloadTask)
        case .content(let coins):
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(coins, id: \.id) { coin in
                        VStack(spacing: 0) {
                            NavigationLink(destination: CoinDetailView(coin: coin)) {
                                CoinRowView(coin: coin)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .contentShape(Rectangle())
                                    .background(Color(.systemBackground))
                            }
                            .buttonStyle(.plain)
                            

                            Divider()
                                .padding(.leading, 52)
                                .padding(.trailing, 8)
                                .opacity(0.3)
                        }
                        .task{
                            await coinListViewModel.loadMoreIfNeeded(currentCoin: coin)
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                
                if coinListViewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
            }
            
        }
    }
}
