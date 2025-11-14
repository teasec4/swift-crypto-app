//
//  CoinRepository.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//

import Foundation

protocol CoinRepositoryProtocol {
    func getCoins(page: Int, limit: Int) async throws -> [Coin]
    func getTopCoins(limit: Int) async throws -> [Coin]
    func getSimplePrices(for coinIDs: [String]) async throws -> [String: Double]
    func invalidatePricesCache()
    func invalidateTopCoinsCache()
    func invalidateAllCoinsCache()
}

@MainActor
final class CoinRepository: CoinRepositoryProtocol {
    private let dataFetcher: CoinDataFetchingService
    private let priceFetcher: SimplePriceFetchingService
    private let errorMapper: ErrorMappingService
    
    // Кэш для топ монет (30 минут)
    private var topCoinsCache: (data: [Coin], timestamp: Date)?
    private let topCoinsCacheDuration: TimeInterval = 1800
    
    // Кэш для всех монет (постраничная выборка) - 30 минут
    private var allCoinsCache: [Int: (data: [Coin], timestamp: Date)] = [:]
    private let allCoinsCacheDuration: TimeInterval = 1800
    
    // Кэш для цен (1 минута)
    private var pricesCache: (data: [String: Double], timestamp: Date)?
    private let pricesCacheDuration: TimeInterval = 60
    
    init(
        dataFetcher: CoinDataFetchingService,
        priceFetcher: SimplePriceFetchingService,
        errorMapper: ErrorMappingService = CoinErrorMappingService()
    ) {
        self.dataFetcher = dataFetcher
        self.priceFetcher = priceFetcher
        self.errorMapper = errorMapper
    }
    
    func getCoins(page: Int, limit: Int) async throws -> [Coin] {
        do {
            // Проверяем кэш
            if let cached = allCoinsCache[page],
               Date().timeIntervalSince(cached.timestamp) < allCoinsCacheDuration {
                print("💾 Using cached coins for page \(page)")
                return cached.data
            }
            
            let coins = try await dataFetcher.fetchCoins(page: page, limit: limit)
            // Сохраняем в кэш если получили данные
            if !coins.isEmpty {
                allCoinsCache[page] = (coins, Date())
            }
            return coins
        } catch {
            // Пытаемся вернуть из кэша при ошибке
            if let cached = allCoinsCache[page] {
                print("⚠️ Network error, using cached coins for page \(page)")
                return cached.data
            }
            throw errorMapper.mapError(error)
        }
    }
    
    func getTopCoins(limit: Int) async throws -> [Coin] {
        do {
            // Проверяем кэш
            if let cached = topCoinsCache,
               Date().timeIntervalSince(cached.timestamp) < topCoinsCacheDuration {
                print("💾 Using cached top coins")
                return cached.data
            }
            
            var all: [Coin] = []
            var page = 1
            let pageSize = 250
            
            while all.count < limit {
                let coins = try await self.dataFetcher.fetchCoins(page: page, limit: pageSize)
                if coins.isEmpty { break }
                all += coins
                page += 1
                
                if all.count >= limit { break }
            }
            
            let result = Array(all.prefix(limit))
            topCoinsCache = (result, Date())
            return result
        } catch {
            // Пытаемся вернуть из кэша при ошибке
            if let cached = topCoinsCache {
                print("⚠️ Network error, using cached top coins")
                return cached.data
            }
            topCoinsCache = nil
            throw errorMapper.mapError(error)
        }
    }
    
    func getSimplePrices(for coinIDs: [String]) async throws -> [String: Double] {
        do {
            // Проверяем кэш
            if let cached = pricesCache,
               Date().timeIntervalSince(cached.timestamp) < pricesCacheDuration {
                print("💾 Using cached prices")
                return cached.data
            }
            
            let prices = try await self.priceFetcher.fetchSimplePrices(for: coinIDs)
            // ✅ Валидация: убеждаемся что цены > 0
            let validatedPrices = prices.filter { $0.value > 0 }
            pricesCache = (validatedPrices, Date())
            return validatedPrices
        } catch {
            // Пытаемся вернуть из кэша при ошибке
            if let cached = pricesCache {
                print("⚠️ Network error, using cached prices")
                return cached.data
            }
            pricesCache = nil
            throw errorMapper.mapError(error)
        }
    }
    
    func invalidatePricesCache() {
        pricesCache = nil
        print("🗑️ Prices cache invalidated")
    }
    
    func invalidateTopCoinsCache() {
        topCoinsCache = nil
        print("🗑️ Top coins cache invalidated")
    }
    
    func invalidateAllCoinsCache() {
        allCoinsCache.removeAll()
        print("🗑️ All coins cache invalidated")
    }
}
