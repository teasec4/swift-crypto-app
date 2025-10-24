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
    
    enum ScreenState{
        case loading
        case error(String)
        case empty
        case content([Coin])
    }
    
    private let repository: CoinRepositoryProtocol
    private(set) var currentPage = 1
    private var canLoadMore = true
    
    
    init(repository: CoinRepositoryProtocol? = nil) {
        self.repository = repository ?? DependencyContainer.shared.coinRepository
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
    
    // use fuzzy match
    var filteredCoins : [Coin] {
        if allCoinsCache.isEmpty {
                return []
            }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filteredByText = query.isEmpty
        ? allCoinsCache
        : allCoinsCache.filter { coin in
            fuzzyMatch(coin.name.lowercased(), query)
            || fuzzyMatch(coin.symbol.lowercased(), query)
        }
        
        
        switch selectedScope {
        case .top10: return filteredByText
                .sorted(by: { ($0.marketCapRank ?? 0) < ($1.marketCapRank ?? 0) })
                .prefix(10)
                .map { $0 }
        case .defi:
            return filteredByText.filter { $0.name.localizedCaseInsensitiveContains("defi") }
        case .ai:
            return filteredByText.filter {
                $0.name.range(of: #"\bAI\b"#, options: [.regularExpression, .caseInsensitive]) != nil
            }
        default:
            return filteredByText
        }
    }
    
    // fuzzy search
    private func fuzzyMatch(_ text: String, _ pattern: String) -> Bool {
        if text.contains(pattern) { return true }
        // delete sapce and symbols
        let normalizedText = text.replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
        let normalizedPattern = pattern.replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
        
        // check for first letter (ex: btc → bitcoin)
        if normalizedText.hasPrefix(normalizedPattern) { return true }
        
        // match by subsequence (b-t-c → bitcoin)
        var tIndex = normalizedText.startIndex
        for ch in normalizedPattern {
            if let found = normalizedText[tIndex...].firstIndex(of: ch) {
                tIndex = normalizedText.index(after: found)
            } else {
                return false
            }
        }
        return true
    }
    
    // levenshtein search
    //    private func levenshtein(_ lhs: String, _ rhs: String) -> Int {
    //        let lhs = Array(lhs)
    //        let rhs = Array(rhs)
    //        var dist = Array(0...rhs.count)
    //        for (i, l) in lhs.enumerated() {
    //            var newDist = [i + 1]
    //            for (j, r) in rhs.enumerated() {
    //                newDist.append(
    //                    l == r ? dist[j] : min(dist[j], dist[j + 1], newDist[j]) + 1
    //                )
    //            }
    //            dist = newDist
    //        }
    //        return dist.last!
    //    }
    
    // and use it
    //    return allCoins.filter {
    //        levenshtein($0.name.lowercased(), query) < 3 ||
    //        levenshtein($0.symbol.lowercased(), query) < 2
    //    }
}
