//
//  CoinRepository.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//

import Foundation

protocol CoinRepositoryProtocol {
    func getCoins(page: Int, limit: Int) async throws -> [Coin]
}

final class CoinRepository: CoinRepositoryProtocol {
    private let api: CoinAPI
    
    init(api: CoinAPI = CoinAPI()) {
        self.api = api
    }
    
    func getCoins(page: Int, limit: Int) async throws -> [Coin] {
        do {
            return try await api.fetchCoins(page: page, limit: limit)
        } catch let urlError as URLError {
            switch urlError.code {
            case .badURL:
                throw CoinError.invalidURL
            case .badServerResponse:
                throw CoinError.serverError
            default:
                throw CoinError.unkown(urlError)
            }
        } catch let decodingError as DecodingError {
            throw CoinError.invalidData
        } catch {
            throw CoinError.unkown(error)
        }
    }
    
}
