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
            List(coins, id: \.id) { coin in
                NavigationLink(destination: CoinDetailView(coin: coin)) {
                    CoinRowView(coin: coin)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .refreshable {
                await coinListViewModel.loadCoins()
            }
            
        }
    }
}
