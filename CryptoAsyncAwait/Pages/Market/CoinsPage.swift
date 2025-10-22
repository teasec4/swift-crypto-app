//
//  CoinsPage.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//

import SwiftUI

struct CoinsPage: View {
    
    @StateObject private var globalMarketViewModel = GlobalMarketViewModel()
    @StateObject private var coinListViewModel = CoinListViewModel()
    
    
    var body: some View {

            VStack{
                GlobalMarketHeaderView(viewModel: globalMarketViewModel)
                CoinListView(coinListViewModel: coinListViewModel)
            }
            
        
    }
}


