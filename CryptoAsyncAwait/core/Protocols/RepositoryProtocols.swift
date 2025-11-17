//
//  RepositoryProtocols.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import Foundation

// MARK: - Coin Repository

protocol CoinRepositoryProtocol {
    func getCoins(page: Int, limit: Int) async throws -> [Coin]
    func getTopCoins(limit: Int) async throws -> [Coin]
    func getSimplePrices(for coinIDs: [String]) async throws -> [String: Double]
    func invalidatePricesCache()
    func invalidateTopCoinsCache()
    func invalidateAllCoinsCache()
}

// MARK: - Chart Repository

protocol ChartRepositoryProtocol {
    func getChartData(for coinID: String, days: Int) async throws -> [PricePoint]
}
