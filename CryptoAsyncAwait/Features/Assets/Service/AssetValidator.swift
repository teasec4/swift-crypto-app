//
//  AssetValidator.swift
//  CryptoAsyncAwait
//
//  Created by AI
//

import Foundation

/// Protocol для валидации операций с ассетами
protocol AssetValidatorProtocol {
    func validateAmount(_ amount: Double) -> Bool
    func validateUserOwnership(_ asset: UserAsset, user: UserEntity) -> Bool
}

final class AssetValidator: AssetValidatorProtocol {
    
    func validateAmount(_ amount: Double) -> Bool {
        return amount > 0
    }
    
    func validateUserOwnership(_ asset: UserAsset, user: UserEntity) -> Bool {
        return asset.user?.email == user.email
    }
}
