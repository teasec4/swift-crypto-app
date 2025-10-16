//
//  CryptoAsyncAwaitTests.swift
//  CryptoAsyncAwaitTests
//
//  Created by Максим Ковалев on 10/16/25.
//
import XCTest
@testable import CryptoAsyncAwait

final class MockCoinRepository: CoinRepositoryProtocol {
    var shouldThrowError = false
    var coinsToReturn: [Coin] = []

    func getCoins(page: Int, limit: Int) async throws -> [Coin] {
        if shouldThrowError {
            throw URLError(.badServerResponse)
        }
        return coinsToReturn
    }
}
