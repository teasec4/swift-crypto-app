//
//  DependencyContainer.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

final class DependencyContainer {
    // MARK: - Singleton
    
    static let shared = DependencyContainer()
    
    // MARK: - Private Properties
    
    private let networkService: NetworkServiceProtocol
    private let coinAPI: CoinAPI
    
    // MARK: - Public Repositories
    
    let coinRepository: CoinRepositoryProtocol
    let chartDataRepository: ChartRepositoryProtocol
    
    // MARK: - Public Services
    
    let coinSearchService: CoinSearchServiceProtocol
    let errorMappingService: ErrorMappingService
    let userPersistenceService: UserPersistenceServiceProtocol
    
    // MARK: - Initialization
    
    private init() {
        // Networking
        self.networkService = NetworkService()
        self.coinAPI = CoinAPI(network: networkService)
        
        // Services
        self.coinSearchService = CoinSearchService()
        self.errorMappingService = CoinErrorMappingService()
        self.userPersistenceService = UserPersistenceService()
        
        // Repositories
        self.coinRepository = CoinRepository(
            dataFetcher: coinAPI,
            priceFetcher: coinAPI,
            errorMapper: errorMappingService
        )
        self.chartDataRepository = ChartDataRepository(dataFetcher: coinAPI)
    }
}
