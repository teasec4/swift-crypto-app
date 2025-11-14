//
//  CoinError+Mapping.swift
//  CryptoAsyncAwait
//
//  Created by AI
//

import Foundation

/// Protocol для маппинга ошибок сети в доменные ошибки
protocol ErrorMappingService {
    func mapError(_ error: Error) -> CoinError
}

final class CoinErrorMappingService: ErrorMappingService {
    func mapError(_ error: Error) -> CoinError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .badURL:
                return .invalidURL
            case .badServerResponse:
                return .serverError
            default:
                return .unkown(urlError)
            }
        }
        
        if error is DecodingError {
            return .invalidData
        }
        
        return .unkown(error)
    }
}
