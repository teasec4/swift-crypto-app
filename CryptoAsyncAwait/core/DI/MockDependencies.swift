//
//  MockDependencies.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import Foundation
import SwiftData

// MARK: - Mock Services for Testing

/// Mock Repository для использования в unit tests и previews
final class MockCoinRepository: CoinRepositoryProtocol {
    var shouldThrowError = false
    var mockCoins: [Coin] = []
    var mockPrices: [String: Double] = [:]
    
    func getCoins(page: Int, limit: Int) async throws -> [Coin] {
        if shouldThrowError {
            throw CoinError.networkError("Mock error")
        }
        return mockCoins
    }
    
    func getTopCoins(limit: Int) async throws -> [Coin] {
        if shouldThrowError {
            throw CoinError.networkError("Mock error")
        }
        return mockCoins.prefix(limit).map { $0 }
    }
    
    func getSimplePrices(for coinIDs: [String]) async throws -> [String: Double] {
        if shouldThrowError {
            throw CoinError.networkError("Mock error")
        }
        return mockPrices
    }
    
    func invalidatePricesCache() {}
    func invalidateTopCoinsCache() {}
    func invalidateAllCoinsCache() {}
}

/// Mock Chart Repository для использования в tests
final class MockChartDataRepository: ChartRepositoryProtocol {
    var shouldThrowError = false
    var mockChartData: [PricePoint] = []
    
    func getChartData(for coinID: String, days: Int) async throws -> [PricePoint] {
        if shouldThrowError {
            throw CoinError.networkError("Mock error")
        }
        return mockChartData
    }
}

/// Mock Search Service
final class MockCoinSearchService: CoinSearchServiceProtocol {
    func searchCoins(_ query: String, in coins: [Coin]) -> [Coin] {
        coins.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    func filterByScope(_ coins: [Coin], scope: MarketsListViewModel.SearchScope) -> [Coin] {
        // Simplified implementation for testing
        switch scope {
        case .all:
            return coins
        case .top10:
            return coins.prefix(10).map { $0 }
        case .defi, .ai:
            return coins
        }
    }
}

/// Mock Persistence Service
final class MockUserPersistenceService: UserPersistenceServiceProtocol {
    var shouldThrowError = false
    var savedUsers: [UserEntity] = []
    
    func saveUser(_ user: UserEntity, context: SwiftData.ModelContext) throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        savedUsers.append(user)
    }
}

/// Mock Asset Validator
final class MockAssetValidator: AssetValidatorProtocol {
    var shouldValidateAmount = true
    var shouldValidateOwnership = true
    
    func validateAmount(_ amount: Double) -> Bool {
        shouldValidateAmount && amount > 0
    }
    
    func validateUserOwnership(_ asset: UserAsset, user: UserEntity) -> Bool {
        shouldValidateOwnership
    }
}

// MARK: - Test Factory for DI

/// Factory для использования mock'ов в тестах
final class TestDependencyFactory: DependencyFactory {
    let mockCoinRepository = MockCoinRepository()
    let mockChartRepository = MockChartDataRepository()
    let mockSearchService = MockCoinSearchService()
    let mockErrorMappingService = CoinErrorMappingService()
    let mockPersistenceService = MockUserPersistenceService()
    
    var coinRepository: CoinRepositoryProtocol { mockCoinRepository }
    var chartDataRepository: ChartRepositoryProtocol { mockChartRepository }
    var coinSearchService: CoinSearchServiceProtocol { mockSearchService }
    var errorMappingService: ErrorMappingService { mockErrorMappingService }
    var userPersistenceService: UserPersistenceServiceProtocol { mockPersistenceService }
}

// MARK: - Test Helpers

/// Вспомогательные функции для создания тестовых данных
enum TestDataFactory {
    static func makeMockCoin(
        id: String = "bitcoin",
        name: String = "Bitcoin",
        symbol: String = "btc",
        currentPrice: Double = 50000,
        marketCapRank: Int? = nil,
        priceChange24H: Double? = nil,
        priceChangePercentage24H: Double? = nil
    ) -> Coin {
        Coin(
            id: id,
            symbol: symbol,
            name: name,
            image: "",
            currentPrice: currentPrice,
            marketCapRank: marketCapRank,
            priceChange24H: priceChange24H,
            priceChangePercentage24H: priceChangePercentage24H
        )
    }
    
    static func makeMockPricePoint(
        date: Date = Date(),
        price: Double = 50000
    ) -> PricePoint {
        PricePoint(date: date, price: price)
    }
}
