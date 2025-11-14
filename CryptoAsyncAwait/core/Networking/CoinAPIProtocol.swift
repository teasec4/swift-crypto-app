//
//  CoinAPIProtocol.swift
//  CryptoAsyncAwait
//
//  Created by AI
//

import Foundation

/// Protocol для получения данных о монетах
protocol CoinDataFetchingService {
    func fetchCoins(page: Int, limit: Int) async throws -> [Coin]
}

/// Protocol для получения глобальных данных рынка
protocol GlobalMarketDataFetchingService {
    func fetchGlobalData() async throws -> GlobalMarketData
}

/// Protocol для получения данных графиков
protocol ChartDataFetchingService {
    func fetchChartData(for coinID: String, days: Int) async throws -> [PricePoint]
}

/// Protocol для получения цен
protocol SimplePriceFetchingService {
    func fetchSimplePrices(for coinIDs: [String]) async throws -> [String: Double]
}
