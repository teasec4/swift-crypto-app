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
    func test_fetchCoins_successfullyUpdatesState() async throws{
        // given
        let mockRepo = MockCoinRepository()
        mockRepo.coinsToReturn = [
                    Coin(id: "btc", symbol: "BTC", name: "Bitcoin", image: "", currentPrice: 65000, marketCapRank: 1, priceChange24H: 1000, priceChangePercentage24H: 1.8)
                ]
        let viewModel = CoinListViewModel(repository: mockRepo)
         
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
        func test_loadCoins_setsEmptyState_whenNoCoinsReturned() async {
            // given
            let mockRepo = MockCoinRepository()
            mockRepo.coinsToReturn = []
            let viewModel = CoinListViewModel(repository: mockRepo)
            
            // when
            await viewModel.loadCoins()
            
            // then
            switch viewModel.state {
            case .empty:
                XCTAssertTrue(true)
            default:
                XCTFail("Expected .empty state, got \(viewModel.state)")
            }
        }
    
    // MARK: - Error case
       func test_loadCoins_handlesCoinErrorProperly() async {
           // given
           let mockRepo = MockCoinRepository()
           mockRepo.shouldThrowError = true
           let viewModel = CoinListViewModel(repository: mockRepo)
           
           // when
           await viewModel.loadCoins()
           
           // then
           switch viewModel.state {
           case .error(let message):
               XCTAssertEqual(message, "There was an error with the server. Please try again later")
           default:
               XCTFail("Expected .error state, got \(viewModel.state)")
           }
       }
    
    // MARK: - ReloadTask wrapper
        func test_reloadTask_callsLoadCoins() async {
            // given
            let mockRepo = MockCoinRepository()
            mockRepo.coinsToReturn = [
                Coin(id: "eth", symbol: "ETH", name: "Ethereum", image: "", currentPrice: 3500, marketCapRank: 2, priceChange24H: -100, priceChangePercentage24H: -2.5)
            ]
            let viewModel = CoinListViewModel(repository: mockRepo)
            
            // when
            viewModel.reloadTask()
            try? await Task.sleep(nanoseconds: 200_000_000) // подождать выполнение
            
            // then
            switch viewModel.state {
            case .content(let coins):
                XCTAssertEqual(coins.first?.symbol, "ETH")
            default:
                XCTFail("Expected .content state after reloadTask()")
            }
        }
}
