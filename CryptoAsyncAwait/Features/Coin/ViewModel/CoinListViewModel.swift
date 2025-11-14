//
//  CoinListViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//
import Foundation
import Combine

@MainActor
final class CoinListViewModel: ObservableObject {
    @Published var state: ScreenState = .loading
    @Published private(set) var isLoadingMore = false
    @Published var searchText: String = ""
    @Published var selectedScope: SearchScope = .all
    
    @Published private(set) var allCoinsCache: [Coin] = []
    @Published private(set) var isLoadingSearch = false
    @Published var allCoinsLoadingErrorMessage: String? = nil
    
    enum SearchScope: String, CaseIterable, Identifiable {
        case all = "All"
        case top10 = "Top 10"
        case defi = "DeFi"
        case ai = "AI"
        
        var id: String { rawValue }
    }
    
    enum ScreenState {
        case loading
        case error(String)
        case empty
        case content([Coin])
    }
    
    private let repository: CoinRepositoryProtocol
    private let searchService: CoinSearchServiceProtocol
    private(set) var currentPage = 1
    private var canLoadMore = true
    
    
    init(
        repository: CoinRepositoryProtocol? = nil,
        searchService: CoinSearchServiceProtocol = CoinSearchService()
    ) {
        self.repository = repository ?? DependencyContainer.shared.coinRepository
        self.searchService = searchService
    }
    
    func loadCoins() async {
        state = .loading
        currentPage = 1
        canLoadMore = true
        do {
            let coins = try await repository.getCoins(page: 1, limit: 50)
            state = coins.isEmpty ? .empty : .content(coins)
        } catch let coinError as CoinError{
            state = .error(coinError.errorDescription ?? "Unexpected error")
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func loadCoinsForSearch() async {
        guard allCoinsCache.isEmpty else { return }
        isLoadingSearch = true
        allCoinsLoadingErrorMessage = nil
        defer { isLoadingSearch = false }
        do {
            let coins = try await repository.getTopCoins(limit: 500)
            allCoinsCache = coins
            allCoinsLoadingErrorMessage = nil
        } catch {
            allCoinsLoadingErrorMessage = error.localizedDescription
        }
    }
    
    func loadMoreIfNeeded(currentCoin: Coin) async {
        guard case .content(let existingCoins) = state else { return }
        guard !isLoadingMore, canLoadMore else { return }
        
        
        if let index = existingCoins.firstIndex(where: { $0.id == currentCoin.id }),
           index >= existingCoins.count - 3 {
            
            isLoadingMore = true
            defer { isLoadingMore = false }
            
            do {
                currentPage += 1
                let newCoins = try await repository.getCoins(page: currentPage, limit: 50)
                canLoadMore = !newCoins.isEmpty
                state = .content(existingCoins + newCoins)
            } catch {
                
                canLoadMore = false
            }
        }
    }
    
    func reloadTask() {
        Task {
            await loadCoins()
        }
    }
    
    var filteredCoins: [Coin] {
        guard !allCoinsCache.isEmpty else { return [] }
        
        let searchedCoins = searchService.search(allCoinsCache, by: searchText)
        return searchService.filterByScope(searchedCoins, scope: selectedScope)
    }
}
