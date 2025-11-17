//
//  DataFetchingProtocols.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import Foundation

// MARK: - Coin Data Fetching

protocol CoinDataFetchingService {
    func fetchCoins(page: Int, limit: Int) async throws -> [Coin]
}

// MARK: - Chart Data Fetching

protocol ChartDataFetchingService {
    func fetchChartData(for coinID: String, days: Int) async throws -> [PricePoint]
}

// MARK: - Simple Price Fetching

protocol SimplePriceFetchingService {
    func fetchSimplePrices(for coinIDs: [String]) async throws -> [String: Double]
}
