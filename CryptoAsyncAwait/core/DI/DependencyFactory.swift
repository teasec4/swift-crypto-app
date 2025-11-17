//
//  DependencyFactory.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import Foundation

/// Протокол для создания зависимостей (возможна замена при тестировании)
protocol DependencyFactory {
    var coinRepository: CoinRepositoryProtocol { get }
    var chartDataRepository: ChartRepositoryProtocol { get }
    var coinSearchService: CoinSearchServiceProtocol { get }
    var errorMappingService: ErrorMappingService { get }
    var userPersistenceService: UserPersistenceServiceProtocol { get }
}

/// Реализация DependencyFactory для использования в production
final class ProductionDependencyFactory: DependencyFactory {
    private lazy var networkService: NetworkServiceProtocol = NetworkService()
    
    private lazy var coinAPI: CoinAPI = {
        CoinAPI(network: networkService)
    }()
    
    private lazy var coinSearchServiceInstance: CoinSearchServiceProtocol = {
        CoinSearchService()
    }()
    
    private lazy var errorMappingServiceInstance: ErrorMappingService = {
        CoinErrorMappingService()
    }()
    
    private lazy var userPersistenceServiceInstance: UserPersistenceServiceProtocol = {
        UserPersistenceService()
    }()
    
    private lazy var coinRepositoryInstance: CoinRepositoryProtocol = {
        CoinRepository(
            dataFetcher: coinAPI,
            priceFetcher: coinAPI,
            errorMapper: errorMappingServiceInstance
        )
    }()
    
    private lazy var chartDataRepositoryInstance: ChartRepositoryProtocol = {
        ChartDataRepository(dataFetcher: coinAPI)
    }()
    
    var coinRepository: CoinRepositoryProtocol {
        coinRepositoryInstance
    }
    
    var chartDataRepository: ChartRepositoryProtocol {
        chartDataRepositoryInstance
    }
    
    var coinSearchService: CoinSearchServiceProtocol {
        coinSearchServiceInstance
    }
    
    var errorMappingService: ErrorMappingService {
        errorMappingServiceInstance
    }
    
    var userPersistenceService: UserPersistenceServiceProtocol {
        userPersistenceServiceInstance
    }
}
