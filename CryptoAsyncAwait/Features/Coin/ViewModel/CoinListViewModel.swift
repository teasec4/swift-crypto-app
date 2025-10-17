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
    @Published var hasLoadedInitially = false

    private let repository: CoinRepositoryProtocol
    
    // Resolve dependency inside init to avoid referencing actor-isolated shared container in default parameter
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
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = "No internet connection."
            case .badURL:
                errorMessage = "Invalid API URL."
            case .badServerResponse:
                errorMessage = "Server error."
            default:
                errorMessage = "Network error: \(urlError.localizedDescription)"
            }
        } else {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
        print("❌ Error: \(errorMessage ?? "")")
    }
}
