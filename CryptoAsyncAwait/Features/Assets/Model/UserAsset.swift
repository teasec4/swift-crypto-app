//
//  UserAsset.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//
import Foundation
import SwiftData

@Model
final class UserAsset {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var coinID: String
    var coinName: String
    var coinSymbol: String
    var coinImage: String
    var coinPrice: Double
    
    
    var user: UserEntity?

    init(coin: Coin, amount: Double, user: UserEntity?) {
        self.id = UUID()
        self.amount = amount
        self.coinID = coin.id
        self.coinName = coin.name
        self.coinSymbol = coin.symbol
        self.coinImage = coin.image
        self.coinPrice = coin.currentPrice
        self.user = user
    }
}

extension UserAsset {
    var coin: Coin {
        Coin(
            id: coinID,
            symbol: coinSymbol,
            name: coinName,
            image: coinImage,
            currentPrice: coinPrice,
            marketCapRank: nil,
            priceChange24H: nil,
            priceChangePercentage24H: nil
        )
    }
}
