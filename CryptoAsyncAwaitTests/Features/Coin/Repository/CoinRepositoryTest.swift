//
//  CoinRepositoryTests.swift
//  CryptoAsyncAwaitTests
//
//  Created by Максим Ковалев on 10/16/25.
//
import XCTest
@testable import CryptoAsyncAwait

@MainActor
final class CoinRepositoryTests: XCTestCase {

    var mockRepo: MockCoinRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockCoinRepository()
    }

    override func tearDown() {
        mockRepo = nil
        super.tearDown()
    }

    // MARK: ✅ Success case
    func test_getCoins_returnsExpectedCoins() async throws {
        // given
        mockRepo.coinsToReturn = [.mockBTC, .mockETH]

        // when
        let coins = try await mockRepo.getCoins(page: 1, limit: 2)

        // then
        XCTAssertEqual(coins.count, 2)
        XCTAssertEqual(coins.first?.id, "btc")
        XCTAssertEqual(coins.last?.id, "eth")
        XCTAssertEqual(coins[0].currentPrice, 65000)
        XCTAssertEqual(coins[1].currentPrice, 3500)
    }

    // MARK: ❌ Error case
    func test_getCoins_throwsCoinErrorWhenFlagSet() async {
        // given
        mockRepo.shouldThrowError = true

        // when / then
        do {
            _ = try await mockRepo.getCoins(page: 1, limit: 10)
            XCTFail("Expected CoinError.serverError, but none was thrown.")
        } catch let error as CoinError {
            XCTAssertEqual(error, .serverError)
            XCTAssertEqual(error.errorDescription, "There was an error with the server. Please try again later")
        } catch {
            XCTFail("Expected CoinError, got \(type(of: error))")
        }
    }
}
