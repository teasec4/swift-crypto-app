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
}
