//
//  CoinDetailViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/21/25.
//
import XCTest
@testable import CryptoAsyncAwait

@MainActor
final class CoinDetailViewModelTests: XCTestCase{
    func test_fetchChartData_successfulLoad_updatesChartData() async throws{
        // given
        let mockRepo = MockCoinRepository()
        let now = Date()
        mockRepo.charData = [
            PricePoint(date: now.addingTimeInterval(-3600), price: 65000.0),
            PricePoint(date: now, price: 65500.0)
        ]
        
        let viewModel = CoinDetailViewModel(repository: mockRepo)
        
        // when
        await viewModel.fetchChartData(for: "btc", days: 1)
        // then
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false after load")
        XCTAssertTrue(viewModel.errorMessage == nil, "errorMessage should be nil on success")
        XCTAssertEqual(viewModel.chartData.count, 2)
        XCTAssertEqual(viewModel.chartData.first?.price, 65000.0)
        XCTAssertEqual(viewModel.chartData.last?.price, 65500.0)
    }
    
    func test_fetchChartData_failure_setsErrorMessage() async {
            // given
            let mockRepo = MockCoinRepository()
            mockRepo.shouldThrowError = true
            
            let viewModel = CoinDetailViewModel(repository: mockRepo)
            
            // when
            await viewModel.fetchChartData(for: "btc", days: 7)
            
            // then
            XCTAssertFalse(viewModel.isLoading, "isLoading should be false after failure")
            XCTAssertNotNil(viewModel.errorMessage, "errorMessage should be set after failure")
            XCTAssertTrue(viewModel.chartData.isEmpty, "chartData should remain empty on error")
        }
        
}
