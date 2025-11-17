//
//  NetworkProtocols.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ url: URL) async throws -> T
    func requestRawJSON(_ url: URL) async throws -> [String: Any]
}
