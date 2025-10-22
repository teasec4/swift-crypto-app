//
//  NetworkService.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/15/25.
//
import Foundation
import Alamofire

protocol NetworkServiceProtocol{
    func request<T: Decodable>(_ url: URL) async throws -> T
    func requestRawJSON(_ url: URL) async throws -> [String: Any]
}

final class NetworkService: NetworkServiceProtocol{
    private let session: Session
    private let logger = NetworkLogger()
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 30
        self.session = Session(configuration: configuration)
    }
    
    func request<T: Decodable>(_ url: URL) async throws -> T {
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
            throw error
        }
        guard let value = response.value else {
            throw URLError(.cannotParseResponse)
        }
        return value
    }
    
    func requestRawJSON(_ url: URL) async throws -> [String: Any] {
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
}

