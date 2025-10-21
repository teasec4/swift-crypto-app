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
    @Published var coins: [Coin] = []
    @Published var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasLoadedInitially = false
    
    enum ScreenState{
        case loading
        case error(String)
        case empty
        case content([Coin])
    }
    
    var screenState: ScreenState {
        if isLoading {return .loading}
        if let error = errorMessage {return .error(error)}
        return coins.isEmpty ? .empty : .content(coins)
    }
    

    private let repository: CoinRepositoryProtocol
    
    
    init(repository: CoinRepositoryProtocol? = nil) {
        self.repository = repository ?? DependencyContainer.shared.coinRepository
    }

    func loadCoins() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let loadedCoins = try await repository.getCoins(page: 1, limit: 50)
            coins = loadedCoins
            hasLoadedInitially = true
            print("✅ Loaded \(loadedCoins.count) coins successfully")
        } catch {
            handleError(error)
        }
    }

    func clearError() { errorMessage = nil }

    private func handleError(_ error: Error) {
        if let urlError = error as? URLError {
            errorMessage = switch urlError.code {
            case .notConnectedToInternet: "No internet connection."
            case .badURL: "Invalid API URL."
            case .badServerResponse: "Server error."
            default: "Network error: \(urlError.localizedDescription)"
            }
        } else {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
        print("❌ Error:", errorMessage ?? "Unknown")
    }
}
