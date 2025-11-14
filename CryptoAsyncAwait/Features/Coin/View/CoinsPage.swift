//
//  CoinsPage.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//

import SwiftUI

struct CoinsPage: View {
    @EnvironmentObject var pageViewModel: CoinsPageViewModel
    @EnvironmentObject var globalMarketViewModel: GlobalMarketViewModel
    @EnvironmentObject var coinListViewModel: CoinListViewModel
    @EnvironmentObject var addAssetViewModel: AddAssetViewModel
    @EnvironmentObject var assetsViewModel: AssetsViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                GlobalMarketHeaderView(viewModel: globalMarketViewModel)
                CoinsListContainer()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        pageViewModel.openAddAssetModal()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $pageViewModel.showAddAssetModal) {
                AddAssetModalView(coinListViewModel: coinListViewModel, viewModel: addAssetViewModel)
                    .environmentObject(assetsViewModel)
            }
        }
    }
}

// MARK: - Container Views

struct CoinsListContainer: View {
    @EnvironmentObject var coinListViewModel: CoinListViewModel
    
    var body: some View {
        CoinListView(coinListViewModel: coinListViewModel)
    }
}
