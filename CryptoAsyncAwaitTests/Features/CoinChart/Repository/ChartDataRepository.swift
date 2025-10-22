//
//  ChartDataRepository.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/21/25.
//
import XCTest
import Foundation
@testable import CryptoAsyncAwait

@MainActor
final class MockGlobalRepositoryTests: XCTestCase{
    
    var mockRepo: MockCoinRepository!
    var now: Date!
    
    override func setUp() {
        super.setUp()
        mockRepo = MockCoinRepository()
        now = Date()
    }
    
    override func tearDown() {
        mockRepo = nil
        now = nil
        super.tearDown()
    }
    
    
    func test_getChartData_returnExpectedData() async throws{
        // given
        mockRepo.charData = makeMockChartData()
        
        // when
        let result = try await mockRepo.getChartData(for: "bitcoin", days: 1)
        
        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.price, 65000.0)
        XCTAssertEqual(result.last?.price, 65500.0)
    }
    
    func test_getChartData_throwsCoinErrorWhenFlagSet() async {
        // given
        mockRepo.shouldThrowError = true
        
        // when / then
        do {
            _ = try await mockRepo.getChartData(for: "btc", days: 1)
            XCTFail("Expected CoinError.serverError, but none was thrown.")
        } catch let error as CoinError {
            XCTAssertEqual(error, .serverError)
            XCTAssertEqual(
                error.errorDescription,
                "There was an error with the server. Please try again later"
            )
        } catch {
            XCTFail("Expected CoinError, but got \(type(of: error))")
        }
    }
    
    // MARK: - Helpers
    
    private func makeMockChartData() -> [PricePoint] {
        [
            PricePoint(date: now.addingTimeInterval(-3600), price: 65000.0),
            PricePoint(date: now, price: 65500.0)
        ]
    }
}
