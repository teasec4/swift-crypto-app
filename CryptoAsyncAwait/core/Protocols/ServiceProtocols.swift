//
//  ServiceProtocols.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import Foundation
import SwiftData

// MARK: - Error Mapping

protocol ErrorMappingService {
    func mapError(_ error: Error) -> Error
}

// MARK: - User Persistence

protocol UserPersistenceServiceProtocol {
    func saveUser(_ user: UserEntity, context: ModelContext) throws
}

// MARK: - Asset Validation

protocol AssetValidatorProtocol {
    func validateAmount(_ amount: Double) -> Bool
    func validateUserOwnership(_ asset: UserAsset, user: UserEntity) -> Bool
}

// MARK: - Coin Search

protocol CoinSearchServiceProtocol {
    func searchCoins(_ query: String, in coins: [Coin]) -> [Coin]
    func filterByScope(_ coins: [Coin], scope: MarketsListViewModel.SearchScope) -> [Coin]
}
