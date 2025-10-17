//
//  MockNetworkService.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/17/25.
//
@testable import CryptoAsyncAwait
import Foundation

final class MockNetworkService: NetworkServiceProtocol{
    var requestedUrl: URL?
    var shouldThrowError = false
    var mockData: Any?
    
    func request<T>(_ url: URL) async throws -> T where T : Decodable {
        requestedUrl = url
        
        if shouldThrowError{
            throw URLError(.badServerResponse)
        }
        
        guard let value = mockData as? T else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return value
    }
    
    func requestRawJSON(_ url: URL) async throws -> [String : Any] {
        requestedUrl = url
        if shouldThrowError{
            throw URLError(.cannotDecodeContentData)
        }
        guard let value = mockData as? [String : Any] else {
            throw URLError(.cannotDecodeContentData)
        }
        return value
    }
    
    
}
