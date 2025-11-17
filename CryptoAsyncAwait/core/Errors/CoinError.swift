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
    case networkError(String)  // ✅ More specific for network issues
    case unknown(String)        // ✅ Changed from "unkown" to "unknown"
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"  // ✅ Was empty string
        case .serverError:
            return "There was an error with the server. Please try again later"
        case .invalidData:
            return "The coin data is invalid. Please try again later"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknown(let message):  // ✅ Changed from "unkown"
            return message
        }
    }
    
    static func == (lhs: CoinError, rhs: CoinError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.serverError, .serverError),
             (.invalidData, .invalidData):
            return true
        case (.networkError(let lMsg), .networkError(let rMsg)):
            return lMsg == rMsg
        case (.unknown(let lMsg), .unknown(let rMsg)):  // ✅ Changed from "unkown"
            return lMsg == rMsg
        default:
            return false
        }
    }
}
