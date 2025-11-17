//
//  NetworkService.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/15/25.
//
import Foundation
import Alamofire

final class NetworkService: NetworkServiceProtocol {
    private let session: Session
    private let logger = NetworkLogger()
    
    // ✅ Retry configuration
    private let maxRetries = 3
    private let retryDelay: UInt64 = 500_000_000  // 0.5 seconds in nanoseconds
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 30
        self.session = Session(configuration: configuration)
    }
    
    func request<T: Decodable>(_ url: URL) async throws -> T {
        return try await requestWithRetry(url, attempt: 1)
    }
    
    // ✅ Вспомогательный метод с retry логикой
    private func requestWithRetry<T: Decodable>(_ url: URL, attempt: Int) async throws -> T {
        let startTime = Date()
        logger.logRequest(url: url)
        
        let dataTask = session.request(url)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self, decoder: JSONDecoder())
        
        let response = await dataTask.response
        let duration = Date().timeIntervalSince(startTime)
        
        logger.logResponse(
            url: url,
            statusCode: response.response?.statusCode ?? 0,
            data: response.data,
            duration: duration
        )
        
        if let error = response.error {
            // ✅ Retry на timeout ошибках
            if isRetryable(error) && attempt < maxRetries {
                print("🔄 Retrying request (attempt \(attempt + 1)/\(maxRetries))...")
                try await Task.sleep(nanoseconds: retryDelay * UInt64(attempt))
                return try await requestWithRetry(url, attempt: attempt + 1)
            }
            throw error
        }
        
        guard let value = response.value else {
            throw URLError(.cannotParseResponse)
        }
        
        return value
    }
    
    func requestRawJSON(_ url: URL) async throws -> [String: Any] {
        return try await requestRawJSONWithRetry(url, attempt: 1)
    }
    
    // ✅ Вспомогательный метод с retry логикой для raw JSON
    private func requestRawJSONWithRetry(_ url: URL, attempt: Int) async throws -> [String: Any] {
        let startTime = Date()
        logger.logRequest(url: url)
        
        let dataTask = session.request(url)
            .validate(statusCode: 200..<300)
            .serializingData()
        
        let response = await dataTask.response
        let duration = Date().timeIntervalSince(startTime)
        
        logger.logResponse(
            url: url,
            statusCode: response.response?.statusCode ?? 0,
            data: response.data,
            duration: duration
        )
        
        if let error = response.error {
            // ✅ Retry на timeout ошибках
            if isRetryable(error) && attempt < maxRetries {
                print("🔄 Retrying raw JSON request (attempt \(attempt + 1)/\(maxRetries))...")
                try await Task.sleep(nanoseconds: retryDelay * UInt64(attempt))
                return try await requestRawJSONWithRetry(url, attempt: attempt + 1)
            }
            throw error
        }
        
        guard
            let data = response.data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            throw URLError(.cannotParseResponse)
        }
        
        return json
    }
    
    // ✅ Определяем, какие ошибки можно retry'ить
    private func isRetryable(_ error: Error) -> Bool {
        if let afError = error as? AFError {
            switch afError {
            case .sessionTaskFailed(let error):
                // ✅ Retry на timeout и network connection issues
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .timedOut, .networkConnectionLost, .notConnectedToInternet:
                        return true
                    default:
                        return false
                    }
                }
                return false
            default:
                return false
            }
        }
        
        // ✅ Проверяем URLError напрямую
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .networkConnectionLost, .notConnectedToInternet:
                return true
            default:
                return false
            }
        }
        
        return false
    }
}
