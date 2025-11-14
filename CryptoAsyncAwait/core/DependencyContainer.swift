//
//  DependencyContainer.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/15/25.
//
final class DependencyContainer {
    // singltone
    static let shared = DependencyContainer()
    
    // MARK: - Networking
    private let networkService: NetworkServiceProtocol
    private let coinAPI: CoinAPI
    
    // MARK: - Repositories
    let coinRepository: CoinRepositoryProtocol
    let globalMarketRepository: GlobalRepositoryProtocol
    let chartDataRepository: ChartRepositoryProtocol
    
    // MARK: - Services
    let coinSearchService: CoinSearchServiceProtocol
    let errorMappingService: ErrorMappingService
    let userPersistenceService: UserPersistenceServiceProtocol
    
    private init() {
        // Networking
        self.networkService = NetworkService()
        self.coinAPI = CoinAPI(network: networkService)
        
        // Services
        self.coinSearchService = CoinSearchService()
        self.errorMappingService = CoinErrorMappingService()
        self.userPersistenceService = UserPersistenceService()
        
        // Repositories
        // ✅ Caching integrated directly into repositories
        self.coinRepository = CoinRepository(
            dataFetcher: coinAPI,
            priceFetcher: coinAPI,
            errorMapper: errorMappingService
        )
        self.globalMarketRepository = GlobalRepository(dataFetcher: coinAPI)
        self.chartDataRepository = ChartDataRepository(dataFetcher: coinAPI)
    }
}
