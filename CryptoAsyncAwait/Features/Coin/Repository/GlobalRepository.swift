//
//  GlobalRepository.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/16/25.
//

import Foundation

protocol GlobalRepositoryProtocol {
    func getGlobalData() async throws -> GlobalMarketData
}

@MainActor
final class GlobalRepository: GlobalRepositoryProtocol {
    private let dataFetcher: GlobalMarketDataFetchingService
    private var cachedData: (data: GlobalMarketData, timestamp: Date)?
    private let cacheDuration: TimeInterval = 60 // 1 минута
    
    init(dataFetcher: GlobalMarketDataFetchingService) {
        self.dataFetcher = dataFetcher
    }
    
    func getGlobalData() async throws -> GlobalMarketData {
        // Проверяем, есть ли свежий кэш
        if let cached = cachedData,
           Date().timeIntervalSince(cached.timestamp) < cacheDuration {
            return cached.data
        }
        
        // Загружаем свежие данные
        let data = try await dataFetcher.fetchGlobalData()
        cachedData = (data, Date())
        return data
    }
    
    func invalidateCache() {
        cachedData = nil
    }
}
