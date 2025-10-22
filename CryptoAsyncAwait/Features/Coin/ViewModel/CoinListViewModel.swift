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
    
    enum ScreenState{
        case loading
        case error(String)
        case empty
        case content([Coin])
    }
    

    private let repository: CoinRepositoryProtocol
    
    
    init(repository: CoinRepositoryProtocol? = nil) {
        self.repository = repository ?? DependencyContainer.shared.coinRepository
    }

    func loadCoins() async {
        state = .loading

        do {
            let coins = try await repository.getCoins(page: 1, limit: 50)
            state = coins.isEmpty ? .empty : .content(coins)
        } catch let coinError as CoinError{
            state = .error(coinError.errorDescription ?? "Unexpected error")
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func reloadTask() {
            Task {
                await loadCoins()
            }
        }
}
