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
    private let dataFetcher: ChartDataFetchingService
    
    init(dataFetcher: ChartDataFetchingService) {
        self.dataFetcher = dataFetcher
    }
    
    func getChartData(for coinID: String, days: Int) async throws -> [PricePoint] {
        try await dataFetcher.fetchChartData(for: coinID, days: days)
    }
}

