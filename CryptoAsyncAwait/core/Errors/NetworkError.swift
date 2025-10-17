//
//  NetworkError.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/16/25.
//
import Foundation

enum NetworkError: LocalizedError {
    case invalidStatusCode(Int)
    case decodingFailed(Error)
    case invalidResponse
    case noData
    case parsingFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidStatusCode(let code): return "Server returned status code \(code)"
        case .decodingFailed: return "Failed to decode response"
        case .invalidResponse: return "Invalid server response"
        case .noData: return "Empty response data"
        case .parsingFailed: return "Failed to parse JSON"
        case .unknown(let error): return error.localizedDescription
        }
    }
}
