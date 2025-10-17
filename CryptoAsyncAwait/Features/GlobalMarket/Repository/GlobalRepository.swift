//
//  GlobalRepository.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/16/25.
//

protocol GlobalRepositoryProtocol {
    func getGlobalData() async throws -> GlobalMarketData
}

final class GlobalRepositoryImplementation: GlobalRepositoryProtocol {
    private let api: CoinAPI
    
    init(api: CoinAPI) {
        self.api = api
    }
    
    func getGlobalData() async throws -> GlobalMarketData {
        try await api.fetchGlobalData()
    }
}
