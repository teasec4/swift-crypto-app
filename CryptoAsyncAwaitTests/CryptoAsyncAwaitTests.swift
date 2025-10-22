//
//  MockCoinRepository.swift
//  CryptoAsyncAwaitTests
//
//  Created by Максим Ковалев on 10/16/25.
//

import XCTest
@testable import CryptoAsyncAwait

final class MockCoinRepository: CoinRepositoryProtocol, ChartRepositoryProtocol, GlobalRepositoryProtocol {
    
    // MARK: - Control flags
    var shouldThrowError = false
    
    // MARK: - Mocked return data
    var coinsToReturn: [Coin] = []
    var charData: [PricePoint] = []
    var globalData: GlobalMarketData?
    
    // MARK: - CoinRepositoryProtocol
    func getCoins(page: Int, limit: Int) async throws -> [Coin] {
        if shouldThrowError {
            throw CoinError.serverError
        }
        return coinsToReturn
    }
    
    // MARK: - ChartRepositoryProtocol
    func getChartData(for coinID: String, days: Int) async throws -> [PricePoint] {
        if shouldThrowError {
            throw CoinError.serverError
        }
        try? await Task.sleep(nanoseconds: 200_000_000) // simulate delay (0.2s)
        return charData
    }
    
    // MARK: - GlobalRepositoryProtocol
    func getGlobalData() async throws -> GlobalMarketData {
        if shouldThrowError {
            throw CoinError.serverError
        }
        guard let globalData = globalData else {
            throw CoinError.invalidData
        }
        return globalData
    }
}

extension Coin{
    static var mockBTC: Coin{
        Coin(
            id: "btc",
            symbol: "BTC",
            name: "Bitcoin",
            image: "",
            currentPrice: 65000,
            marketCapRank: 1,
            priceChange24H: 1200,
            priceChangePercentage24H: 1.8
        )
    }
    
    static let mockETH = Coin(
            id: "eth",
            symbol: "ETH",
            name: "Ethereum",
            image: "https://example.com/eth.png",
            currentPrice: 3500,
            marketCapRank: 2,
            priceChange24H: -150,
            priceChangePercentage24H: -2.1
        )
}

extension GlobalMarketData {
    static let mockUptrend = GlobalMarketData(
        totalMarketCap: ["usd": 2_500_000_000_000],
        totalVolume: ["usd": 150_000_000_000],
        marketCapChangePercentage24hUsd: 2.4
    )
    
    static let mockDowntrend = GlobalMarketData(
        totalMarketCap: ["usd": 2_300_000_000_000],
        totalVolume: ["usd": 100_000_000_000],
        marketCapChangePercentage24hUsd: -1.8
    )
}


