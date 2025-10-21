//
//  GlobalMarketViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/9/25.
//
import Foundation
import Combine

@MainActor
final class GlobalMarketViewModel: ObservableObject {
    @Published var totalMarketCap: Double?
    @Published var change24h: Double?
    @Published var totalVolume: Double?
    @Published var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let repository: GlobalRepositoryProtocol
    
    init(repository: GlobalRepositoryProtocol? = nil) {
           self.repository = repository ?? DependencyContainer.shared.globalMarketRepository
       }
    
    
    func loadGlobalData() async {
        print("🌐 GlobalMarketViewModel.loadGlobalData() called")
        isLoading = true
        defer { isLoading = false }
        
        do {
            let data = try await repository.getGlobalData()
            self.totalMarketCap = data.totalMarketCap?["usd"] ?? 0.0
            self.change24h = data.marketCapChangePercentage24hUsd ?? 0.0
            self.totalVolume = data.totalVolume?["usd"] ?? 0.0
            print("✅ Global data loaded successfully")
        } catch {
            handleError(error)
        }
    }
    
    func clearError() { errorMessage = nil }
    
    private func handleError(_ error: Error) {
        if let coinError = error as? CoinError {
            errorMessage = "\(coinError.localizedDescription)"
        } else {
            errorMessage = "Failed to load global data: \(error.localizedDescription)"
        }
        print("❌ GlobalMarketViewModel error:", errorMessage ?? "")
    }
}
