//
//  ServiceLocator.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//
import Foundation

class ServiceLocator{
    
    private var services: [String: Any] = [:]
    
    static var shared: ServiceLocator = ServiceLocator()
    
    private init(){}
    
//    private init(){
//        // activate configuration
//        let coinListService = configureCoinListService()
//        let coinListServicekey = String(describing: coinListServiceProtocol.self)
//        
//        // save to service locator
//        services[coinListServicekey] = coinListService
//    }
    
    
    func addService<T>(_ service:T){
        let key = String(describing: T.self)
        services[key] = service
    }
    
    func getService<T>() -> T? {
        let key = String(describing: T.self)
        return services[key] as? T
    }
    
    // configuration a service
//    private func configure coinListService() -> coinListServiceProtocol{
//        coinListService()
//    }
}
