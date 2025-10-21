//
//  GlobalMarketViewModelTest.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/21/25.
//
import XCTest
@testable import CryptoAsyncAwait

@MainActor
final class GlobalMarketViewModelTests: XCTestCase{
    
    func test_loadGlobalData_successfullyUpdateValues() async throws{
        // given
        let mockRepo = MockCoinRepository()
        mockRepo.globalData = GlobalMarketData(
            totalMarketCap: ["usd" : 1_234_567_890], totalVolume: ["usd": 987_654_321], marketCapChangePercentage24hUsd: 2.5
        )
        
        let viewModel = GlobalMarketViewModel(repository: mockRepo)
        
        // when
        await viewModel.loadGlobalData()
        
        //then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.totalMarketCap, 1_234_567_890)
        XCTAssertEqual(viewModel.totalVolume, 987_654_321)
        XCTAssertEqual(viewModel.change24h, 2.5)
    }
    
    func test_loadGLobalData_handlesErrorGracefully() async {
        // given
        let mockRepo = MockCoinRepository()
        mockRepo.shouldThrowError = true
        
        let viewModel = GlobalMarketViewModel(repository: mockRepo)
        
        // when
        await viewModel.loadGlobalData()
        
        //then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.totalMarketCap)
        XCTAssertNil(viewModel.totalVolume)
    }
    
}

