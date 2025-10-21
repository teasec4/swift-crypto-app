//
//  ChartDataRepository.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/21/25.
//
import XCTest
import Foundation
@testable import CryptoAsyncAwait

final class MockGlobalRepositoryTests: XCTestCase{
    func test_getChartData_returnExpectedData() async throws{
        // given
        let mockRepo = MockCoinRepository()
        let now = Date()
        mockRepo.charData = [
            PricePoint(date: now.addingTimeInterval(-3600), price: 65000.0),
            PricePoint(date: now, price: 65500.0)
        ]
        
        // when
        let result = try await mockRepo.getChartData(for: "bitcoin", days: 1)
        
        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.price, 65000.0)
        XCTAssertEqual(result.last?.price, 65500.0)
    }
    
    func test_getChartData_throwsErrorWhenFlagSet() async {
        // given
        let mockRepo = MockCoinRepository()
        mockRepo.shouldThrowError = true
        
        // when / then
        do {
            _ = try await mockRepo.getChartData(for: "btc", days: 1)
            XCTFail("Expected an error to be thrown, but none was thrown.")
        } catch {
            guard let urlError = error as? URLError else {
                XCTFail("Expected URLError but got \(type(of: error))")
                return
            }
            XCTAssertEqual(urlError.code, .badServerResponse)
        }
    }
}
