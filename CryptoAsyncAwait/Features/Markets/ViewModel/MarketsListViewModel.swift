//
//  MarketsListViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import Foundation
import Combine

@MainActor
final class MarketsListViewModel: ObservableObject {
    @Published var state: ScreenState = .loading
    @Published private(set) var isLoadingMore = false
    @Published var searchText: String = ""
    @Published var selectedScope: SearchScope = .all
    @Published private(set) var hasAttemptedLoad = false
    
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
    
    // ✅ Защита от race conditions при загрузке
    private var loadingTask: Task<Void, Never>?
    private var searchLoadingTask: Task<Void, Never>?
    
    // ✅ Retry логика
    private let maxRetries = 3
    private var retryCount = 0
    
    init(
        repository: CoinRepositoryProtocol? = nil,
        searchService: CoinSearchServiceProtocol = CoinSearchService()
    ) {
        self.repository = repository ?? DependencyContainer.shared.coinRepository
        self.searchService = searchService
    }
    
    func loadCoins() async {
        // ✅ Отменяем предыдущую загрузку если она идёт
        loadingTask?.cancel()
        
        loadingTask = Task {
            // ✅ Проверяем отмену сразу в начале
            guard !Task.isCancelled else { return }
            
            state = .loading
            hasAttemptedLoad = true
            currentPage = 1
            canLoadMore = true
            retryCount = 0
            
            await loadCoinsWithRetry(page: 1, limit: 50)
        }
    }
    
    // ✅ Вспомогательный метод с retry логикой
    private func loadCoinsWithRetry(page: Int, limit: Int) async {
        do {
            // ✅ Проверяем отмену перед каждым запросом
            guard !Task.isCancelled else { return }
            
            let coins = try await repository.getCoins(page: page, limit: limit)
            
            // ✅ Ещё раз проверяем после получения результата
            guard !Task.isCancelled else { return }
            
            state = coins.isEmpty ? .empty : .content(coins)
            retryCount = 0
        } catch let coinError as CoinError {
            // ✅ Не обновляем state если Task отменён
            guard !Task.isCancelled else { return }
            
            if retryCount < maxRetries {
                retryCount += 1
                print("🔄 Retrying coin load (attempt \(retryCount)/\(maxRetries))...")
                try? await Task.sleep(nanoseconds: UInt64(retryCount * 500_000_000)) // 0.5s, 1s, 1.5s
                await loadCoinsWithRetry(page: page, limit: limit)
            } else {
                state = .error(coinError.errorDescription ?? "Failed to load coins after \(maxRetries) attempts")
            }
        } catch {
            // ✅ Не обновляем state если Task отменён
            guard !Task.isCancelled else { return }
            
            if retryCount < maxRetries {
                retryCount += 1
                print("🔄 Retrying coin load (attempt \(retryCount)/\(maxRetries))...")
                try? await Task.sleep(nanoseconds: UInt64(retryCount * 500_000_000))
                await loadCoinsWithRetry(page: page, limit: limit)
            } else {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func ensureCoinsLoadedForSearch() async {
        // ✅ Если монеты уже загружены, ничего не делаем
        guard allCoinsCache.isEmpty && !isLoadingSearch else { return }
        
        // ✅ Отменяем предыдущую загрузку если она идёт
        searchLoadingTask?.cancel()
        
        isLoadingSearch = true
        allCoinsLoadingErrorMessage = nil
        
        searchLoadingTask = Task {
            await loadCoinsForSearchWithRetry()
            isLoadingSearch = false
        }
    }
    
    // ✅ Вспомогательный метод с retry логикой для поиска (загружает 500 монет для поиска)
    private func loadCoinsForSearchWithRetry(retryAttempt: Int = 0) async {
        do {
            let coins = try await repository.getTopCoins(limit: 500)
            allCoinsCache = coins
            allCoinsLoadingErrorMessage = nil
            print("✅ Loaded \(coins.count) coins for search")
        } catch {
            if retryAttempt < maxRetries {
                print("🔄 Retrying search load (attempt \(retryAttempt + 1)/\(maxRetries))...")
                try? await Task.sleep(nanoseconds: UInt64((retryAttempt + 1) * 500_000_000))
                await loadCoinsForSearchWithRetry(retryAttempt: retryAttempt + 1)
            } else {
                allCoinsLoadingErrorMessage = error.localizedDescription
                print("❌ Failed to load coins for search: \(error.localizedDescription)")
            }
        }
    }
    
    func loadMoreIfNeeded(currentCoin: Coin) async {
        guard case .content(let existingCoins) = state else { return }
        guard !isLoadingMore, canLoadMore else { return }
        
        // ✅ Проверяем, нужно ли загружать ещё (находимся ближе к концу)
        if let index = existingCoins.firstIndex(where: { $0.id == currentCoin.id }),
           index >= existingCoins.count - 3 {
            
            isLoadingMore = true
            defer { isLoadingMore = false }
            
            do {
                currentPage += 1
                let newCoins = try await repository.getCoins(page: currentPage, limit: 50)
                canLoadMore = !newCoins.isEmpty
                
                // ✅ Проверяем что state всё ещё содержит те же монеты перед добавлением
                if case .content(let currentCoins) = state {
                    state = .content(currentCoins + newCoins)
                }
            } catch {
                print("❌ Failed to load more coins:", error)
                canLoadMore = false
            }
        }
    }
    
    func reloadTask() {
        Task {
            await loadCoins()
        }
    }
    
    // ✅ Инвалидировать кэши перед обновлением
    func invalidateCaches() {
        if let repository = repository as? CoinRepository {
            repository.invalidateAllCoinsCache()
            repository.invalidatePricesCache()
        }
    }
    
    var filteredCoins: [Coin] {
        guard !allCoinsCache.isEmpty else { return [] }
        
        let searchedCoins = searchService.searchCoins(searchText, in: allCoinsCache)
        return searchService.filterByScope(searchedCoins, scope: selectedScope)
    }
}
