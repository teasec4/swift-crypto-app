//
//  CoinListViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/22/25.
//
import XCTest
@testable import CryptoAsyncAwait

@MainActor
final class CoinListViewModelTests: XCTestCase{
    
    var mockRepo: MockCoinRepository!
    var viewModel: CoinListViewModel!
    
    override func setUp() {
        super.setUp()
        mockRepo = MockCoinRepository()
        viewModel = CoinListViewModel(repository: mockRepo)
    }
    
    override func tearDown() {
            mockRepo = nil
            viewModel = nil
            super.tearDown()
    }
    
    func test_fetchCoins_successfullyUpdatesState() async throws{
        // given
        mockRepo.coinsToReturn = [Coin.mockBTC]
         
        // when
        await viewModel.loadCoins()
        
        // then
        switch viewModel.state{
        case .content(let coins):
            XCTAssertEqual(coins.count, 1)
            XCTAssertEqual(coins.first?.name, "Bitcoin")
        default:
            XCTFail("Expected .content state, got \(viewModel.state)")
        }
    }
    
    // MARK: - Empty case
    func test_loadCoins_empty() async {
            mockRepo.coinsToReturn = []
            await viewModel.loadCoins()
            if case .empty = viewModel.state {} else {
                XCTFail("Expected .empty state")
            }
        }
    
    // MARK: - Error case
    func test_loadCoins_error() async {
            mockRepo.shouldThrowError = true
            await viewModel.loadCoins()
            if case .error(let msg) = viewModel.state {
                XCTAssertEqual(msg, "There was an error with the server. Please try again later")
            } else {
                XCTFail("Expected .error state")
            }
        }
    
    // MARK: - ReloadTask wrapper
        func test_reloadTask_callsLoadCoins() async {
            // given
            mockRepo.coinsToReturn = [Coin.mockBTC]
            
            // when
            viewModel.reloadTask()
            try? await Task.sleep(nanoseconds: 200_000_000) // подождать выполнение
            
            // then
            switch viewModel.state {
            case .content(let coins):
                XCTAssertEqual(coins.first?.symbol, "BTC")
            default:
                XCTFail("Expected .content state after reloadTask()")
            }
        }
}
