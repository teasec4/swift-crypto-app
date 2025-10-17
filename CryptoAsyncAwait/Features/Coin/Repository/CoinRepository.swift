//
//  CoinRepository.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//

import Foundation

protocol CoinRepositoryProtocol {
    func getCoins(page: Int, limit: Int) async throws -> [Coin]
}

final class CoinRepository: CoinRepositoryProtocol {
    private let api: CoinAPI
    
    init(api: CoinAPI = CoinAPI()) {
        self.api = api
    }
    
    func getCoins(page: Int, limit: Int) async throws -> [Coin] {
        try await api.fetchCoins(page: page, limit: limit)
    }
    
}
