//
//  MarketsPage.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import SwiftUI

struct MarketsPage: View {
    @EnvironmentObject var coinListViewModel: MarketsListViewModel
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    
    var body: some View {
        MarketsListView(coinListViewModel: coinListViewModel)
            .environmentObject(portfolioViewModel)
    }
}
