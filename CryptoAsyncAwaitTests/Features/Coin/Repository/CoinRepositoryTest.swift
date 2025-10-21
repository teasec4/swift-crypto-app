//
//  CoinRepositoryTest.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/16/25.
//
import XCTest
@testable import CryptoAsyncAwait

final class MockCoinRepositoryTests: XCTestCase {

    func test_getCoins_returnsExpectedCoins() async throws {
        // given
        let mockRepo = MockCoinRepository()
        mockRepo.coinsToReturn = [
            Coin(
                id: "btc",
                symbol: "btc",
                name: "Bitcoin",
                image: "https://example.com/btc.png",
                currentPrice: 65000,
                marketCapRank: 1,
                priceChange24H: 1200,
                priceChangePercentage24H: 1.8
            ),
            Coin(
                id: "eth",
                symbol: "eth",
                name: "Ethereum",
                image: "https://example.com/eth.png",
                currentPrice: 3500,
                marketCapRank: 2,
                priceChange24H: -150,
                priceChangePercentage24H: -2.1
            )
        ]

        // when
        let coins = try await mockRepo.getCoins(page: 1, limit: 2)

        // then
        XCTAssertEqual(coins.count, 2)
        XCTAssertEqual(coins.first?.id, "btc")
        XCTAssertEqual(coins.last?.name, "Ethereum")
        XCTAssertEqual(coins[0].currentPrice, 65000)
        XCTAssertEqual(coins[1].priceChangePercentage24H, -2.1)
    }

    func test_getCoins_throwsErrorWhenFlagSet() async {
        // given
        let mockRepo = MockCoinRepository()
        mockRepo.shouldThrowError = true

        // when / then
            do {
                _ = try await mockRepo.getCoins(page: 1, limit: 10)
                XCTFail("Expected an error to be thrown, but none was thrown.")
            } catch {
                // type of error
                guard let urlError = error as? URLError else {
                    XCTFail("Expected URLError but got \(type(of: error))")
                    return
                }
                XCTAssertEqual(urlError.code, .badServerResponse)
            }
    }
}
