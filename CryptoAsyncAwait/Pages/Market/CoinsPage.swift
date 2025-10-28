//
//  CoinsPage.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//

import SwiftUI

struct CoinsPage: View {
    // view model for content on CoinsPage
    @ObservedObject var globalMarketViewModel: GlobalMarketViewModel
    @ObservedObject var coinListViewModel: CoinListViewModel
    
    // for transport to FullScreenCoverAddAssetsView ( think to change to EnviromentObjet)
    @ObservedObject var assetsViewModel: AssetsViewModel
    
    
    // open full screen cover for search assets
    @State private var isOpenSheet: Bool = false
    
    // creating a state for form
    @StateObject private var formState = AssetFormState()
    
    var body: some View {
        // Content
            VStack{
                GlobalMarketHeaderView(viewModel: globalMarketViewModel)
                CoinListView(coinListViewModel: coinListViewModel)
            }
        // open fullScreenCover button
            .toolbar{
                ToolbarItem(placement:.primaryAction){
                    Button{
                        isOpenSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        // full screencover sheet (better to change coinListView for new VM for search)
            .fullScreenCover(isPresented:$isOpenSheet){
                FullScreenCoverAddAssetsView(coinListViewModel:coinListViewModel, assetsViewModel: assetsViewModel, formState: formState)
            }
    }
    
}


