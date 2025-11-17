//
//  MarketDetailViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import Foundation
import Combine

/// ViewModel для отображения деталей рынка и графиков
@MainActor
final class MarketDetailViewModel: ObservableObject {
    @Published var chartData: [PricePoint] = []
    @Published var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: ChartRepositoryProtocol
    
    init(repository: ChartRepositoryProtocol? = nil) {
           self.repository = repository ?? DependencyContainer.shared.chartDataRepository
       }
        
    
    func fetchChartData(for coinID: String, days: Int = 30) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            chartData = try await repository.getChartData(for: coinID, days: days)
        } catch {
            errorMessage = "Failed to load chart: \(error.localizedDescription)"
        }
    }

    func clearError() { errorMessage = nil }
}
