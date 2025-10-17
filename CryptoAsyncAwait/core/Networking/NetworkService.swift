//
//  NetworkService.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/15/25.
//
import Foundation

protocol NetworkServiceProtocol{
    func request<T: Decodable>(_ url: URL) async throws -> T
    func requestRawJSON(_ url: URL) async throws -> [String: Any]
}

final class NetworkService: NetworkServiceProtocol{
    
    private let session: URLSession
    private let logger = NetworkLogger()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ url: URL) async throws -> T {
        let startTime = Date()
        logger.logRequest(url: url)
        
        let (data, response) = try await session.data(from: url)
        let duration = Date().timeIntervalSince(startTime)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        logger.logResponse(
            url: url,
            statusCode: http.statusCode,
            data: data,
            duration: duration
        )
        
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.invalidStatusCode(http.statusCode)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func requestRawJSON(_ url: URL) async throws -> [String: Any] {
        let startTime = Date()
        logger.logRequest(url: url)
        
        let (data, response) = try await session.data(from: url)
        let duration = Date().timeIntervalSince(startTime)
        
        guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode) else {
                throw NetworkError.invalidResponse
            }
        
        logger.logResponse(
            url: url,
            statusCode: http.statusCode,
            data: data,
            duration: duration
        )
        
        guard http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        
        return json
    }
}

