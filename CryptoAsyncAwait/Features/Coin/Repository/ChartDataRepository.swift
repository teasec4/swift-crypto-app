//
//  ChartDataRepository.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/16/25.
//
protocol ChartRepositoryProtocol {
    func getChartData(for coinID:String, days: Int) async throws -> [PricePoint]
}

final class ChartDataRepository: ChartRepositoryProtocol {
    private let api: CoinAPI
    
    init(api: CoinAPI) {
        self.api = api
    }
    
    func getChartData(for coinID: String, days: Int) async throws -> [PricePoint] {
        try await api.fetchChartData(for: coinID, days:days)
    }
}

