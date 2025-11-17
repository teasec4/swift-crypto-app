//
//  CoinError+Mapping.swift
//  CryptoAsyncAwait
//
//  Created by AI
//

import Foundation

final class CoinErrorMappingService: ErrorMappingService {
    func mapError(_ error: Error) -> Error {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .badURL:
                return CoinError.invalidURL
            case .badServerResponse:
                return CoinError.serverError
            default:
                return CoinError.unkown(urlError)
            }
        }
        
        if error is DecodingError {
            return CoinError.invalidData
        }
        
        return CoinError.unkown(error)
    }
}
