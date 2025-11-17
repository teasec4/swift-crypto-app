//
//  MarketsListView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import SwiftUI
import SwiftData

struct MarketsListView: View {
    @ObservedObject var coinListViewModel: MarketsListViewModel
    @Environment(\.modelContext) private var context
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject private var addAssetViewModel = AddAssetViewModel()
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    
    @State private var initialLoadAttempted = false
    @State private var showAddAssetForm = false
    @State private var selectedCoinForAdd: Coin?
    
    var body: some View {
        NavigationStack {
            bodyContent
                .searchable(text: $coinListViewModel.searchText,
                            placement: .navigationBarDrawer(displayMode: .always),
                            prompt: "Search coins")
                .searchScopes($coinListViewModel.selectedScope) {
                    ForEach(MarketsListViewModel.SearchScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue)
                    }
                }
                .navigationTitle("Markets")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    if !initialLoadAttempted {
                        initialLoadAttempted = true
                        await coinListViewModel.loadCoins()
                        // Загрузим монеты для поиска в фоне
                        await coinListViewModel.ensureCoinsLoadedForSearch()
                    }
                }
                .sheet(isPresented: $showAddAssetForm) {
                    if let coin = selectedCoinForAdd {
                        AddAssetFormView(
                            coin: coin,
                            viewModel: addAssetViewModel
                        )
                        .environmentObject(portfolioViewModel)
                        .presentationDetents([.fraction(0.5)])
                        .presentationDragIndicator(.visible)
                    }
                }
                .onAppear {
                    addAssetViewModel.setPortfolioViewModel(portfolioViewModel)
                }
        }
    }
    
    @ViewBuilder
    private var bodyContent: some View{
        if coinListViewModel.isLoadingSearch && coinListViewModel.searchText.isEmpty == false {
            // Если ищем и загружаем монеты
            VStack(spacing: 10) {
                ForEach(0..<14, id: \.self) { _ in
                    CoinRowSkeletonView()
                }
            }
        } else if !coinListViewModel.searchText.isEmpty && coinListViewModel.filteredCoins.isEmpty {
            // Если ищем, но результатов нет
            VStack(spacing: 16) {
                Text("No coins found")
                    .font(.headline)
                Text("Try searching with different keywords")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        } else if !coinListViewModel.searchText.isEmpty {
            // Показываем результаты поиска
            searchResultsList
        } else {
            // Обычный список монет (пагинированный)
            mainCoinsList
        }
    }
    
    private var mainCoinsList: some View {
        switch coinListViewModel.state {
        case .loading:
            return AnyView(
                VStack(spacing: 10) {
                    ForEach(0..<14, id: \.self) { _ in
                        CoinRowSkeletonView()
                    }
                }
            )
        case .error(let error):
            return AnyView(
                CoinErrorView(message: error, retryAction: coinListViewModel.reloadTask)
            )
        case .empty:
            return AnyView(
                CoinEmptyView(retryAction: coinListViewModel.reloadTask)
            )
        case .content(let coins):
            return AnyView(
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(coins, id: \.id) { coin in
                            coinRowWithActions(coin)
                                .task{
                                    await coinListViewModel.loadMoreIfNeeded(currentCoin: coin)
                                }
                        }
                    }
                    .background(themeManager.backgroundColor)
                    
                    if coinListViewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                }
                .refreshable {
                    coinListViewModel.invalidateCaches()
                    await coinListViewModel.loadCoins()
                }
            )
        }
    }
    
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(coinListViewModel.filteredCoins, id: \.id) { coin in
                    coinRowWithActions(coin)
                }
            }
            .background(themeManager.backgroundColor)
        }
    }
    
    private func coinRowWithActions(_ coin: Coin) -> some View {
        VStack(spacing: 0) {
            Button {
                selectedCoinForAdd = coin
                addAssetViewModel.startAdd(coin: coin)
                showAddAssetForm = true
            } label: {
                CoinRowView(coin: coin)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .contentShape(Rectangle())
                    .background(Color(.systemBackground))
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing) {
                Button {
                    selectedCoinForAdd = coin
                    addAssetViewModel.startAdd(coin: coin)
                    showAddAssetForm = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .tint(.blue)
            }
            
            Divider()
                .padding(.leading, 52)
                .padding(.trailing, 8)
                .opacity(0.3)
        }
    }
}
