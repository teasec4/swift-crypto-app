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
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var addAssetViewModel: AddAssetViewModel
    
    var body: some View {
        MarketsListView()
            .environmentObject(coinListViewModel)
            .environmentObject(portfolioViewModel)
            .environmentObject(themeManager)
            .environmentObject(addAssetViewModel)
    }
}
