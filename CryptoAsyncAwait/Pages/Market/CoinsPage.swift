//
//  CoinsPage.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//

import SwiftUI

struct CoinsPage: View {
    @ObservedObject var globalMarketViewModel: GlobalMarketViewModel
    @ObservedObject var coinListViewModel: CoinListViewModel
    @ObservedObject var assetsViewModel: AssetsViewModel
    @Environment(\.modelContext) private var context
    
    @State private var isOpenSheet: Bool = false
    
    var body: some View {
            VStack{
                GlobalMarketHeaderView(viewModel: globalMarketViewModel)
                CoinListView(coinListViewModel: coinListViewModel)
            }
            .toolbar{
                ToolbarItem(placement:.primaryAction){
                    Button{
                        isOpenSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented:$isOpenSheet){
                FullScreenCoverAddAssetsView(coinListViewModel:coinListViewModel, assetsViewModel: assetsViewModel)
                    .environment(\.modelContext, context)
            }
    }
    
}


