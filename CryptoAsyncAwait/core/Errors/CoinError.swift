//
//  CoinError.swift
//  CryptoAsyncAwait
//
//  Created by Stephan Dowless on 1/5/23.
//

import Foundation

enum CoinError: Error, LocalizedError, Equatable {
    case invalidURL
    case serverError
    case invalidData
    case unkown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return ""
        case .serverError:
            return "There was an error with the server. Please try again later"
        case .invalidData:
            return "The coin data is invalid. Please try again later"
        case .unkown(let error):
            return error.localizedDescription
        }
    }
    
    static func == (lhs: CoinError, rhs: CoinError) -> Bool {
            switch (lhs, rhs) {
            case (.invalidURL, .invalidURL),
                 (.serverError, .serverError),
                 (.invalidData, .invalidData):
                return true
            case (.unkown, .unkown):
                return true
            default:
                return false
            }
        }
    
}
