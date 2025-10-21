//
//  CryptoAsyncAwaitTests.swift
//  CryptoAsyncAwaitTests
//
//  Created by Максим Ковалев on 10/16/25.
//
import XCTest
@testable import CryptoAsyncAwait

final class MockCoinRepository: CoinRepositoryProtocol, ChartRepositoryProtocol, GlobalRepositoryProtocol {
    var shouldThrowError = false
    var coinsToReturn: [Coin] = []
    var charData: [PricePoint] = []
    var globalData: GlobalMarketData!

    func getCoins(page: Int, limit: Int) async throws -> [Coin] {
        if shouldThrowError {
            throw URLError(.badServerResponse)
        }
        return coinsToReturn
    }
    
    func getChartData(for coinID: String, days: Int) async throws -> [PricePoint] {
        if shouldThrowError{
            throw URLError(.badServerResponse)
        }
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 
        return charData
    }
    
    func getGlobalData() async throws -> GlobalMarketData {
        if shouldThrowError{
            throw URLError(.badServerResponse)
        }
        return globalData
    }
}


