//
//  FullScreenCoverAddAssetsView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//

import SwiftUI

struct FullScreenCoverAddAssetsView: View {
    @ObservedObject var coinListViewModel: CoinListViewModel
    @Environment(\.dismiss) var dismiss
    @ObservedObject var assetsViewModel: AssetsViewModel

    
    var body: some View {
        NavigationStack{
            VStack{
                Group{
                    if coinListViewModel.isLoadingSearch{
                        List{
                                ForEach(0..<20, id: \.self) { _ in
                                    CoinRowSkeletonView()
                                }
                            }
                        .listStyle(.plain)
                    } else {
                        List{
                            ForEach(coinListViewModel.filteredCoins){ coin in
                                CoinRowView(coin: coin)
                                    .onTapGesture {
                                        assetsViewModel.selectCoin(coin)
                                    }
                            }
                        }
                        .listStyle(.plain)
                    }
                    
                    if let error = coinListViewModel.allCoinsLoadingErrorMessage {
                        VStack(spacing: 12) {
                            Text("⚠️ Failed to load coins")
                                .font(.headline)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Button("Try Again in a 1 min") {
                                Task { await coinListViewModel.loadCoinsForSearch() }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
                // good feature
//                .searchSuggestions {
//                    ForEach(coinListViewModel.filteredCoins.prefix(5)) { coin in
//                        Button {
//                            
//                        } label: {
//                            CoinRowView(coin: coin)
//                        }
//                    }
//                }
            }
            .searchable(text: $coinListViewModel.searchText,
                            placement: .navigationBarDrawer(displayMode: .always),
                            prompt: "Search coins")
            .searchScopes($coinListViewModel.selectedScope) {
                ForEach(CoinListViewModel.SearchScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue)
                    }
                }
            .navigationTitle("Add Asset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement:.topBarLeading){
                    Button{
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.gray)
                    }
                }
            }
            .task{
                await coinListViewModel.loadCoinsForSearch()
            }
            .sheet(isPresented: $assetsViewModel.showAddSheet){
                AddCoinAmountSheet(assetsViewModel: assetsViewModel)
            }
        }
        
    }
}


