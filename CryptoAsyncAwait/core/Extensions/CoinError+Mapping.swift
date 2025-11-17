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
                return CoinError.unknown(urlError.localizedDescription)
            }
        }
        
        if error is DecodingError {
            return CoinError.invalidData
        }
        
        return CoinError.unknown(error.localizedDescription)
    }
}
