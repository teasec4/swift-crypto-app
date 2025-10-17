//
//  DependencyContainer.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/15/25.
//
final class DependencyContainer {
    static let shared = DependencyContainer()
    private let coinAPI: CoinAPI
    
    let coinRepository: CoinRepositoryProtocol
    let globalMarketRepository: GlobalRepositoryProtocol
    let chartDataRepository: ChartRepositoryProtocol
    
    private init() {
        self.coinAPI = CoinAPI()
        self.coinRepository = CoinRepository(api: coinAPI)
        self.globalMarketRepository = GlobalRepositoryImplementation(api: coinAPI)
        self.chartDataRepository = ChartDataRepository(api: coinAPI)
    }
}
