//
//  CoinRepository.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//

import Foundation

protocol CoinRepositoryProtocol {
    func getCoins(page: Int, limit: Int) async throws -> [Coin]
    func getTopCoins(limit: Int) async throws -> [Coin]
    func getSimplePrices(for coinIDs: [String]) async throws -> [String: Double]
}

final class CoinRepository: CoinRepositoryProtocol {
    private let api: CoinAPI
    
    init(api: CoinAPI) {
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
    
    func getTopCoins(limit: Int) async throws -> [Coin] {
        do {
            var all: [Coin] = []
            var page = 1
            let pageSize = 100
            
            while all.count < limit{
                let coins = try await api.fetchCoins(page: page, limit: pageSize)
                if coins.isEmpty { break }
                all += coins
                page += 1
            }
            
            return Array(all.prefix(limit))
            
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
    
    func getSimplePrices(for coinIDs: [String]) async throws -> [String: Double] {
            do {
                return try await api.fetchSimplePrices(for: coinIDs)
            } catch let urlError as URLError {
                switch urlError.code {
                case .badURL:
                    throw CoinError.invalidURL
                case .badServerResponse:
                    throw CoinError.serverError
                default:
                    throw CoinError.unkown(urlError)
                }
            } catch {
                throw CoinError.unkown(error)
            }
        }
}
