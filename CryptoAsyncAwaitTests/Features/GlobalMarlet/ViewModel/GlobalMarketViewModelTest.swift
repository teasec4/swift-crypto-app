//
//  GlobalMarketViewModelTest.swift
//  CryptoAsyncAwaitTests
//
//  Created by Максим Ковалев on 10/21/25.
//

import XCTest
@testable import CryptoAsyncAwait

@MainActor
final class GlobalMarketViewModelTests: XCTestCase {
    
    var viewModel: GlobalMarketViewModel!
    var mockRepo: MockCoinRepository!
    
    override func setUp(){
        super.setUp()
        mockRepo = MockCoinRepository()
        viewModel = GlobalMarketViewModel(repository: mockRepo)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepo = nil
        super.tearDown()
    }
    
    // MARK:
    func test_loadGlobalData_successfullyUpdatesStateToContent() async throws {
        // given
        mockRepo.globalData = GlobalMarketData(
            totalMarketCap: ["usd": 1_234_567_890],
            totalVolume: ["usd": 987_654_321],
            marketCapChangePercentage24hUsd: 2.5
        )
        
        // when
        await viewModel.loadGlobalData()
        
        // then
        switch viewModel.state {
        case .content(let data):
            XCTAssertEqual(data.totalMarketCap?["usd"], 1_234_567_890)
            XCTAssertEqual(data.totalVolume?["usd"], 987_654_321)
            XCTAssertEqual(data.marketCapChangePercentage24hUsd, 2.5)
        default:
            XCTFail("Expected .content state, but got \(viewModel.state)")
        }
    }
    
    // MARK: - Ошибка загрузки
    func test_loadGlobalData_setsErrorStateOnFailure() async {
        // given
        mockRepo.shouldThrowError = true
        
        // when
        await viewModel.loadGlobalData()
        
        // then
        switch viewModel.state {
        case .error(let message):
            XCTAssertFalse(message.isEmpty)
        default:
            XCTFail("Expected .error state, but got \(viewModel.state)")
        }
    }
    
    // MARK: - Пустые данные
    func test_loadGlobalData_setsEmptyStateWhenNoData() async {
        // given
        mockRepo.globalData = GlobalMarketData(
            totalMarketCap: [:],
            totalVolume: [:],
            marketCapChangePercentage24hUsd: 0
        )
        
        // when
        await viewModel.loadGlobalData()
        
        // then
        switch viewModel.state {
        case .empty:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected .empty state, but got \(viewModel.state)")
        }
    }
}
