//
//  CoinAPITest.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/17/25.
//
import XCTest
@testable import CryptoAsyncAwait

final class CoinAPITests: XCTestCase {
    func test_fetchCoins_success() async throws {
        let mockNetwork = MockNetworkService()
        let api = await CoinAPI(network: mockNetwork)
        
        let fakeCoins: [Coin] = [
            Coin(
                id: "bitcoin", symbol: "btc", name: "Bitcoin",
                image: "https://test.com/btc.png",
                currentPrice: 50000, marketCapRank: 1,
                priceChange24H: 100, priceChangePercentage24H: 1.2
            )
        ]
        mockNetwork.mockData = fakeCoins
        
        let result = try await api.fetchCoins(page: 1, limit: 50)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "bitcoin")
        
        XCTAssertTrue(mockNetwork.requestedUrl?.absoluteString.contains("/coins/markets") ?? false)
        XCTAssertTrue(mockNetwork.requestedUrl?.absoluteString.contains("page=1") ?? false)
        
        let url = mockNetwork.requestedUrl!.absoluteString
        
        XCTAssertTrue(url.contains("vs_currency=usd"))
        XCTAssertTrue(url.contains("page=1"))
        XCTAssertTrue(url.contains("per_page=50"))
    }
    
    func test_fetchCoins_error() async {
        let mockNetwork = MockNetworkService()
        mockNetwork.shouldThrowError = true
        let api = CoinAPI(network: mockNetwork)
        
        do{
            _ = try await api.fetchCoins(page: 1, limit: 50)
            XCTFail("Expected to throw an error")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }
    
    func test_fetchGlobalData_success() async throws {
        // Arrange
        let mockNetwork = MockNetworkService()
        let api = await CoinAPI(network: mockNetwork)
        let fakeGlobalData = GlobalResponse(
            data: GlobalMarketData(
                totalMarketCap: ["usd": 1_000_000_000],
                totalVolume: ["usd": 500_000_000],
                marketCapChangePercentage24hUsd: 2.5
            )
        )
        mockNetwork.mockData = fakeGlobalData
        
        // Act
        let result = try await api.fetchGlobalData()
        
        // Assert
        XCTAssertEqual(result.marketCapChangePercentage24hUsd, 2.5)
        XCTAssertTrue(mockNetwork.requestedUrl?.absoluteString.contains("/global") ?? false)
        
    }
    
    
}
