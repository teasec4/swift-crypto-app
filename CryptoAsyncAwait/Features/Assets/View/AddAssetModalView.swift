//
//  AddAssetModalView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//

import SwiftUI

struct AddAssetModalView: View {
    // VM for searching
    @ObservedObject var coinListViewModel: CoinListViewModel
    @ObservedObject var viewModel: AddAssetViewModel
    
    // close the current sheet option
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // loading screen and fetch coins list
                Group {
                    if coinListViewModel.isLoadingSearch {
                        List {
                            ForEach(0..<20, id: \.self) { _ in
                                CoinRowSkeletonView()
                            }
                        }
                        .listStyle(.plain)
                    } else {
                        List {
                            ForEach(coinListViewModel.filteredCoins) { coin in
                                CoinRowView(coin: coin)
                                    .onTapGesture {
                                        viewModel.startAdd(coin: coin)
                                    }
                            }
                        }
                        .listStyle(.plain)
                    }
                    
                    // if have an error
                    if let error = coinListViewModel.allCoinsLoadingErrorMessage {
                        ZStack {
                            List {
                                ForEach(0..<20, id: \.self) { _ in
                                    CoinRowSkeletonView()
                                }
                            }
                            .listStyle(.plain)
                            
                            VStack(spacing: 12) {
                                Text("⚠️ Failed to load coins")
                                    .font(.headline)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Button("Try Again in 1 min") {
                                    Task { await coinListViewModel.loadCoinsForSearch() }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            // searchable
            .searchable(text: $coinListViewModel.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search coins")
            // sort options
            .searchScopes($coinListViewModel.selectedScope) {
                ForEach(CoinListViewModel.SearchScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue)
                }
            }
            .navigationTitle("Add Asset")
            .navigationBarTitleDisplayMode(.inline)
            // close the sheet
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
            // task for fetching 500 coins from CoinGeckoAPI
            .task {
                await coinListViewModel.loadCoinsForSearch()
            }
            // open the form for selected coin
            .sheet(isPresented: $viewModel.showSheet) {
                if let coin = viewModel.selectedCoin {
                    AddAssetFormView(
                        coin: coin,
                        viewModel: viewModel
                    )
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
                }
            }
        }
    }
}
