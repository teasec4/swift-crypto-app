//
//  Coin.swift
//  CryptoAsyncAwait
//
//  Created by Max Kovalev on 10/9/25.
//

import Foundation

struct Coin: Codable, Identifiable,Hashable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCapRank: Int?
    let priceChange24H: Double?
    let priceChangePercentage24H: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCapRank = "market_cap_rank"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
    }
    
    var imageUrl: URL? {
        guard let url = URL(string: image),
              let scheme = url.scheme,
              scheme == "http" || scheme == "https" else {
            return nil
        }
        return url
    }
}
