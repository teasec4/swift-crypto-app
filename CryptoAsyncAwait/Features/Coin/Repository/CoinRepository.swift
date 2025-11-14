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
}

@MainActor
final class CoinRepository: CoinRepositoryProtocol {
    private let dataFetcher: CoinDataFetchingService
    private let priceFetcher: SimplePriceFetchingService
    private let errorMapper: ErrorMappingService
    
    // Кэш для топ монет (30 минут)
    private var topCoinsCache: (data: [Coin], timestamp: Date)?
    private let topCoinsCacheDuration: TimeInterval = 1800
    
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
            return try await dataFetcher.fetchCoins(page: page, limit: limit)
        } catch {
            throw errorMapper.mapError(error)
        }
    }
    
    func getTopCoins(limit: Int) async throws -> [Coin] {
        do {
            // Проверяем кэш
            if let cached = topCoinsCache,
               Date().timeIntervalSince(cached.timestamp) < topCoinsCacheDuration {
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
            topCoinsCache = nil
            throw errorMapper.mapError(error)
        }
    }
    
    func getSimplePrices(for coinIDs: [String]) async throws -> [String: Double] {
        do {
            // Проверяем кэш
            if let cached = pricesCache,
               Date().timeIntervalSince(cached.timestamp) < pricesCacheDuration {
                return cached.data
            }
            
            let prices = try await self.priceFetcher.fetchSimplePrices(for: coinIDs)
            pricesCache = (prices, Date())
            return prices
        } catch {
            pricesCache = nil
            throw errorMapper.mapError(error)
        }
    }
    
    func invalidatePricesCache() {
        pricesCache = nil
    }
    
    func invalidateTopCoinsCache() {
        topCoinsCache = nil
    }
}
